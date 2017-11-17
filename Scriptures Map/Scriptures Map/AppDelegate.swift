//
//  AppDelegate.swift
//  Scriptures Map
//
//  Created by Misha Milovidov on 11/16/17.
//  Copyright © 2017 Misha Milovidov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    // MARK: - Properties
    
    var window: UIWindow?

    // MARK: - Application lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if let splitViewController = window!.rootViewController as? UISplitViewController {
            splitViewController.delegate = self
        }
        
        return true
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {   
        return true
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        
        if let navVC = primaryViewController as? UINavigationController {
            for controller in navVC.viewControllers {
                if controller.restorationIdentifier == "DetailVC" {
                    return controller
                }
            }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailVC")
        
        return detailVC
    }

}

