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
    
    // MARK: - Properties
    
    var book: Book!
    var chapter = 0
    var geoPlaces = [GeoPlace]()
    
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
        
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Map" {
            let navVC = segue.destination as? UINavigationController
            
            if let mapVC = navVC?.topViewController as? MapViewController {
                // NEEDSWORK: configure the map view controller appropriately
            }
        }
    }
    
    // MARK: - Web kit navigation delegate
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let path = navigationAction.request.url?.absoluteString {
            if path.hasPrefix(ScriptureRenderer.Constant.baseUrl) {
                print("Request: \(path), mapViewController: \(String(describing: mapViewController))")
                
                if let mapVC = mapViewController {
                        // NEEDSWORK: zoom in on the tapped geoplace
                } else {
                    performSegue(withIdentifier: "Show Map", sender: self)
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
