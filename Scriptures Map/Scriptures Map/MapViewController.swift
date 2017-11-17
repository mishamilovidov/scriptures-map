//
//  MapViewController.swift
//  Scriptures Map
//
//  Created by Misha Milovidov on 11/16/17.
//  Copyright © 2017 Misha Milovidov. All rights reserved.
//

import UIKit
import MapKit

class MapViewController : UIViewController, MKMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
    }
}

