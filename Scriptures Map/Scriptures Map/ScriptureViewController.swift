//
//  ScriptureViewController.swift
//  Scriptures Map
//
//  Created by Misha Milovidov on 11/17/17.
//  Copyright © 2017 Misha Milovidov. All rights reserved.
//

import UIKit
import WebKit

class ScriptureViewController : UIViewController, WKNavigationDelegate {
    
    // MARK: - Constants
    
    private struct Storyboard {
        static let MapSegueIdentifier = "Show Map"
    }
    
    enum UIUserInterfaceIdiom : Int
    {
        case Unspecified
        case Phone
        case Pad
    }
    
    struct ScreenSize
    {
        static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
        static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
        static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    }
    
    struct DeviceType
    {
        static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
        static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
        static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
        static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    }
    
    // MARK: - Properties
    
    var book: Book!
    var chapter = 0
    var geoPlaces = [GeoPlace]()
    var selectedGeoPlacePath = ""
    private weak var mapViewController: MapViewController?
    private var webView: WKWebView!
    
    // MARK: - View controller lifecycle
    
    override func loadView() {
        let webViewConfiguration = WKWebViewConfiguration()
        
        webViewConfiguration.preferences.javaScriptEnabled = false
        
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureDetailViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDetailViewController()
        
        let (html, _) = ScriptureRenderer.sharedRenderer.htmlForBookId(book.id, chapter: chapter)
        
        webView.loadHTMLString(html, baseURL: nil)
        
        geoPlaces = retrieveGeoPlaces(in: GeoDatabase.sharedGeoDatabase.versesForScriptureBookId(book.id, chapter))
        
        mapViewController?.geoPlaces = geoPlaces
        mapViewController?.loadAnnotations(from: geoPlaces)
        mapViewController?.title = self.title
        mapViewController?.bookChapter = self.title!
        
        createRightBarButtonItem()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // perform neccessary segues for iPhone Plus flipping back from portrait to landscape
        if UIDevice.current.userInterfaceIdiom == .phone {
            if UIDevice.current.orientation.isLandscape && DeviceType.IS_IPHONE_6P {
                hideRightBarButtonItem()
                performSegue(withIdentifier: Storyboard.MapSegueIdentifier, sender: self)
                self.navigationController?.popViewController(animated: true)
                performSegue(withIdentifier: Storyboard.MapSegueIdentifier, sender: self)
            } else {
                createRightBarButtonItem()
            }
        }
    }

    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.MapSegueIdentifier {
            let navVC = segue.destination as? UINavigationController
            
            if let mapVC = navVC?.topViewController as? MapViewController {
                mapVC.geoPlaces = geoPlaces
                mapVC.requestedGeoPlacePath = selectedGeoPlacePath
                mapVC.title = self.title
                mapVC.bookChapter = self.title!
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func rightButtonAction(sender: UIBarButtonItem) {
        performSegue(withIdentifier: Storyboard.MapSegueIdentifier, sender: self)
    }
    
    // MARK: - Web kit navigation delegate
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let path = navigationAction.request.url?.absoluteString {
            selectedGeoPlacePath = path
            
            if path.hasPrefix(ScriptureRenderer.Constant.baseUrl) {
                if let mapVC = mapViewController {
                    let requestArray = path.components(separatedBy: "/")
                    if let geoPlace = GeoDatabase.sharedGeoDatabase.geoPlaceForId(Int(requestArray.last!)!) {
                        mapVC.geoPlaces = geoPlaces
                        mapVC.loadAnnotation(for: geoPlace)
                    }
                } else {
                    performSegue(withIdentifier: Storyboard.MapSegueIdentifier, sender: self)
                }
                
                decisionHandler(.cancel)
                
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
    // MARK: - Helpers
    
    func configureDetailViewController() {
        if let splitVC = splitViewController {
            if let navVC = splitVC.viewControllers.last as? UINavigationController {
                mapViewController = navVC.topViewController as? MapViewController
            } else {
                mapViewController = splitVC.viewControllers.last as? MapViewController
            }
        } else {
            mapViewController = nil
        }
    }
    
    func createRightBarButtonItem() {
        if geoPlaces.count > 0 && UIDevice.current.userInterfaceIdiom == .phone {
            let rightButtonItem = UIBarButtonItem.init(
                title: "Map",
                style: .done,
                target: self,
                action: #selector(rightButtonAction)
            )
            
            self.navigationItem.rightBarButtonItem = rightButtonItem
        }
    }
    
    func hideRightBarButtonItem() {
        self.navigationItem.rightBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func retrieveGeoPlaces(in verses: [Scripture]) -> [GeoPlace] {
        
        var geoPlaces = [GeoPlace]()
        
        for scripture in verses {
            let geoTags = GeoDatabase.sharedGeoDatabase.geoTagsForScriptureId(scripture.id)
            
            for geoTag in geoTags {
                let geoPlace = GeoDatabase.sharedGeoDatabase.geoPlaceForId(geoTag.1.geoplaceId)
                
                geoPlaces.append(geoPlace!)
            }
        }
        
        return geoPlaces
    }
}
