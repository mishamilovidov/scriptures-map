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

    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        
        mapView.mapType = .hybridFlyover
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2DMake(40.2506, -111.65247)
        annotation.title = "Tanner Building"
        annotation.subtitle = "BYU Campus"
        
        mapView.addAnnotation(annotation)
        
        let camera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2DMake(40.2506, -111.65247), fromEyeCoordinate: CLLocationCoordinate2DMake(40, -111.65247), eyeAltitude: 3000)
        mapView.setCamera(camera, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func setMapRegion(_ sender: Any) {
        let region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(40.2, -111.65), MKCoordinateSpanMake(1, 1))
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Map view delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "Pin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if view == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pinView.canShowCallout = true
            pinView.animatesDrop = true
            pinView.pinTintColor = UIColor.purple
            
            view = pinView
        } else {
            view?.annotation = annotation
        }
        
        return view
    }
    
}

