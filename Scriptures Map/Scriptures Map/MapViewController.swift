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
    
    // MARK: - Properties
    
    var geoPlaces = [GeoPlace]()
    var annotations = [MKPointAnnotation]()
    var requestedGeoPlacePath = ""
    var bookChapter = ""
    
    private var locationManager = CLLocationManager()

    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - View controller lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        
        mapView.mapType = .hybridFlyover
        
        if geoPlaces.count > 0 {
            loadAnnotations(from: geoPlaces)
        }
        
        if !requestedGeoPlacePath.isEmpty {
            let requestArray = requestedGeoPlacePath.components(separatedBy: "/")
            if let geoPlace = GeoDatabase.sharedGeoDatabase.geoPlaceForId(Int(requestArray.last!)!) {
                loadAnnotation(for: geoPlace)
            }
            requestedGeoPlacePath = ""
        }
        
    }
    
    // MARK: - Actions
    
    @IBAction func setMapRegion(_ sender: Any) {
        if geoPlaces.count > 0 {
            loadAnnotations(from: geoPlaces)
            zoomToAnnotationRegion()
            navigationItem.title = bookChapter
        } else {
            loadInitialData()
        }
    }
    
    // MARK: - Map view delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let reuseIdentifier = "Pin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

        if view == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pinView.canShowCallout = true
            pinView.animatesDrop = true

            view = pinView
        } else {
            view?.annotation = annotation
        }
        
        return view
    }
    
    // MARK: - Helpers
    
    func calculateRegionLatitude() -> Double {
        var maxLatitude = mapView.annotations[0].coordinate.latitude
        var minLatitude = mapView.annotations[0].coordinate.latitude
        
        for annotation in mapView.annotations {
            if annotation.coordinate.latitude < minLatitude {
                minLatitude = annotation.coordinate.latitude
            }
            if annotation.coordinate.latitude > maxLatitude {
                maxLatitude = annotation.coordinate.latitude
            }
        }
        
        let regionLatitude = (maxLatitude + minLatitude) / 2
        
        return regionLatitude
    }
    
    func calculateRegionLongitude() -> Double {
        var maxLongitude = mapView.annotations[0].coordinate.longitude
        var minLongitude = mapView.annotations[0].coordinate.longitude
        
        for annotation in mapView.annotations {
            if annotation.coordinate.longitude < minLongitude {
                minLongitude = annotation.coordinate.longitude
            }
            if annotation.coordinate.longitude > maxLongitude {
                maxLongitude = annotation.coordinate.longitude
            }
        }
        
        let regionLongitude = (maxLongitude + minLongitude) / 2
        
        return regionLongitude
    }
    
    func loadInitialData() {
        let initalLatitude = 39.9877296
        let initialLongitude = -93.977757
        
        let region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(initalLatitude, initialLongitude), MKCoordinateSpanMake(180, 180))
        mapView.setRegion(region, animated: true)
    }
    
    func loadAnnotation(for geoPlace: GeoPlace) {
        
        if mapView.annotations.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: geoPlace.latitude, longitude: geoPlace.longitude)
        annotation.title = geoPlace.placename
        
        mapView.addAnnotation(annotation)
        
        zoom(to: geoPlace)
    }
    
    func loadAnnotations(from geoPlaces: [GeoPlace]) {
        
        mapView.removeAnnotations(mapView.annotations)
        
        if geoPlaces.count > 0 {
            for geoPlace in geoPlaces {
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = CLLocationCoordinate2D(latitude: geoPlace.latitude, longitude: geoPlace.longitude)
                annotation.title = geoPlace.placename
                
                mapView.addAnnotation(annotation)
            }
            
            zoomToAnnotationRegion()
        } else {
            loadInitialData()
        }
    }
    
    func zoom(to geoPlace:GeoPlace) {
//        let latitude = annotation.coordinate.latitude
//        let longitude = annotation.coordinate.longitude
//
//        let region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(latitude, longitude), MKCoordinateSpanMake(3, 3))
//        navigationItem.title = annotation.title
//        mapView.setRegion(region, animated: true)
        
        let camera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2DMake(geoPlace.latitude, geoPlace.longitude), fromEyeCoordinate: CLLocationCoordinate2DMake(geoPlace.viewLatitude, geoPlace.viewLongitude), eyeAltitude: geoPlace.viewAltitude)
        navigationItem.title = geoPlace.placename
        mapView.setCamera(camera, animated: true)
    }
    
    func zoomToAnnotationRegion() {
        let regionLatitude = calculateRegionLatitude()
        let regionLongitude = calculateRegionLongitude()
        
        let region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(regionLatitude, regionLongitude), MKCoordinateSpanMake(10, 10))
        mapView.setRegion(region, animated: true)
        
    }
    
}

