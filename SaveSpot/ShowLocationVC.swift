//
//  LastLocationVC.swift
//  SaveSpot
//
//  Created by Anton Kuznetsov on 12/7/15.
//  Copyright © 2015 Anton Kuznetsov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ShowLocationVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var destination : MKMapItem = MKMapItem()
    
    // This value may be passed by `HistoryTVController` in `prepareForSegue(_:sender:)`
    var historySpot: Spot?
    
    let locationMgr = CLLocationManager()
    var myPosition = CLLocationCoordinate2D()
    
    @IBAction func closePressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var mapView: MKMapView!
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let draw = MKPolylineRenderer(overlay: overlay)
        draw.strokeColor = UIColor.purple
        draw.lineWidth = 3.0
        return draw
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg.jpg")!)
        locationMgr.delegate = self
        locationMgr.requestWhenInUseAuthorization()
        locationMgr.startUpdatingLocation()
        loadTheLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadTheLocation(){
        var spot = lastSpot
        var showDirections = true
        if let oldSpot = historySpot {
            //historyspot was passed
            spot = oldSpot
            showDirections = false
        }
        let location = spot!.location
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: center, span: span)
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = spot!.name
        mapView.addAnnotation(annotation)
        mapView.setRegion(region,animated:true)
        myPosition = locationMgr.location!.coordinate
        
         //create a place mark and a map item
        let placeMark = MKPlacemark(coordinate: center, addressDictionary: nil)
        
         //This is needed when we need to get direction
        destination = MKMapItem(placemark: placeMark)
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.requestsAlternateRoutes = false
        
        if !showDirections{
            return
        }
        let directions = MKDirections(request: request)
        directions.calculate{
            response, error in
            guard let response = response else {
                //handle the error here
                return
            }
            let overlays = self.mapView.overlays
            self.mapView.removeOverlays(overlays)
            
            for route in response.routes {
                self.mapView.add(route.polyline,
                    level: MKOverlayLevel.aboveRoads)
                for next  in route.steps {
                    print(next.instructions)
                }
            }
        }
    }
}
