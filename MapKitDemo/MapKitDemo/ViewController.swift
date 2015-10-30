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
            var annotations = [MKAnnotation]()
            for item: MKMapItem in (searchResponse?.mapItems)! {
                let annotation = MKPointAnnotation();
                annotation.coordinate = item.placemark.coordinate;
                annotation.title = item.name;
                annotations.append(annotation)
            }
            
            self.mapView.showAnnotations(annotations, animated: true)
        }
    }
}



