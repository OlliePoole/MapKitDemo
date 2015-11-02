//
//  ViewController.swift
//  MapKitDemo
//
//  Created by Oliver Poole on 26/10/2015.
//  Copyright © 2015 ASOPGM. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationAuthorizationStatus()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    let regionRadius: CLLocationDistance = 10000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - location manager to authorize user location for Maps app
    func checkLocationAuthorizationStatus() {
        if #available(iOS 8.0, *) {
            if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
                mapView.showsUserLocation = true
                
                let location = locationManager.location
                let camera = MKMapCamera()
                camera.centerCoordinate = location!.coordinate
                camera.altitude = 1000
                mapView.setCamera(camera, animated: true)
                
                
            } else {
                locationManager.requestWhenInUseAuthorization()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        let request = MKLocalSearchRequest();
        request.naturalLanguageQuery = searchBar.text
        request.region = self.mapView.region;
        
        let search = MKLocalSearch(request: request);
        
        search.startWithCompletionHandler { (searchResponse: MKLocalSearchResponse?, error: NSError?) -> Void in
            var annotations = [DirectionsPointAnnotation]()
            for item: MKMapItem in (searchResponse?.mapItems)! {
                
                let title = item.name;
                let coordinate = item.placemark.coordinate;
                
                let annotation = DirectionsPointAnnotation(title: title!, coordinate: coordinate, placemark: item.placemark)
                
                annotations.append(annotation)
            }
            
            self.mapView.showAnnotations(annotations, animated: true)
        }
    }
}

extension ViewController : MKMapViewDelegate {
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let annotation = view.annotation as! DirectionsPointAnnotation
        
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = MKMapItem.mapItemForCurrentLocation()
        directionsRequest.destination = MKMapItem(placemark: annotation.placemark)
        
        directionsRequest.transportType = .Any
        
        directionsRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
            if error == nil {
                for route in (response?.routes)! {
                    mapView.addOverlay(route.polyline, level: .AboveRoads)
                }
            }
        }
        
        /*
        This code opens the location in Apple Maps native application
        
        let annotation = view.annotation as! DirectionsPointAnnotation
        let mapItem = MKMapItem(placemark: annotation.placemark)
        mapItem.name = annotation.title
        mapItem.openInMapsWithLaunchOptions(nil)
        */
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKindOfClass(DirectionsPointAnnotation) {
            let identifer = "DirectionsMapAnnotation"
            
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifer)
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:identifer)
                annotationView!.canShowCallout = true
                
                let calloutButton = UIButton(type: .DetailDisclosure)
                calloutButton.setImage(UIImage(named: "Directions Icon"), forState: UIControlState.Normal)
                
                annotationView!.rightCalloutAccessoryView = calloutButton
                
            } else {
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 2.0
        
        return renderer
    }
}




