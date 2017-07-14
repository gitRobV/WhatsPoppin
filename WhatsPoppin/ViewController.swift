//
//  ViewController.swift
//  WhatsPoppin
//
//  Created by Robert on 7/13/17.
//  Copyright © 2017 The Hackathon Winners. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation



class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var poppinMapView: MKMapView!
    
    var startingPoint: CLLocation?
    let geocoder = CLGeocoder()
    var pinPoints: [CLLocationCoordinate2D] = []
    let regionRadius: CLLocationDistance = 100000
    var locationManager = CLLocationManager()
    
    
    
    
    let annotation = MKPointAnnotation()
    
    
    
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius + 2.0, regionRadius * 2.0)
        poppinMapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            poppinMapView.showsUserLocation = true
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 1
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            let initialLocation = CLLocation(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
            startingPoint = initialLocation
            
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
//        var locations = [[Double]]()
        
        var pins = [MKAnnotation]()
        
        
        let FBtoken: String = "EAAbDO1iQ2IUBAOpggSiNZAQhaXi0qSDyk6iGKU4ZAhhWRzAZAP2pFCsvw9a9oTnayj11La4x8AAVoN4qz5TbWTrlCd0VAZBI36zBZCaSuOAdeprZAZCq5dQ6hRUWvxzImxRHCecxwNPu1kLmayZA4rTZBmT2iS8LFAAC8fokePfmDWpFBefAJXR9exTnmjGP2Fx0ZD"
        
        let urlString = "https://graph.facebook.com/search?q=91504&type=event&distance=1000&access_token=" + FBtoken
        
        guard let requestUrl = URL(string:urlString) else { return }
        let request = URLRequest(url:requestUrl)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if error == nil {
                do {
                    if let data = data {
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        let events = json?["data"] as? [[String: Any]]
                        
                        for event in events! {
                            print("****************")
                            print(event["name"]!)
                            print(event["start_time"]!)
                            print(event["end_time"]!)
                            if let location = event["place"] as? [String: Any] {
                                print(location["name"]!)
                                
                                var point: [String:Double] = [
                                    "lat": 0,
                                    "lng": 0
                                ]
                                
                                let Gtooken: String = "AIzaSyBYZVo3dC-d-MOkgEkchiKCQ9sRNDyhVYo"
                                let GrawString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(String(describing: location["name"]!))&key=\(Gtooken)"
                                
                                // let  = "https://maps.googleapis.com/maps/api/geocode/json?address=Cinecert+LLC+2840+N+Lima+St+Burbank,+CA+91504&key=AIzaSyBYZVo3dC-d-MOkgEkchiKCQ9sRNDyhVYo"
                                
                                
                                
                                let GurlString = GrawString.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
                                print(GurlString)
                                guard let requestGurl = URL(string:GurlString) else { return }
                                let Grequest = URLRequest(url: requestGurl)
                                let Gtask = URLSession.shared.dataTask(with: Grequest) {
                                    ( data, response, error ) in
                                    if error == nil {
                                        // You have Data
                                        // Data Format
                                        do {
                                            if let data = data {
                                                if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                                                    if let results = json["results"] {
                                                        let resultArray = results as! NSArray
                                                        if let object = resultArray.firstObject as? NSDictionary {
                                                            if let geoLocation = object["geometry"] as? NSDictionary {
                                                                if let locale = geoLocation["location"] as? NSDictionary {
                                                                    print("this after JSON Serialization: \(locale)")
                                                                    point["lat"] = locale["lat"]! as? Double
                                                                    point["lng"] = locale["lng"]! as? Double
                                                                    print("this is our point\(point)")
                                                                    
                                                                    let pin = MKPointAnnotation()
                                                                    pin.coordinate = CLLocationCoordinate2D(latitude: Double(point["lat"]!), longitude: Double(point["lng"]!))
                                                                    pin.title = "This Works"
                                            
//                                                                    pins.append(pin)
                                                                    print(pin)
                                                                    self.poppinMapView.addAnnotation(pin as MKAnnotation)

                                                                    print("*******")
                                                                }
                                                                
                                                            }
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        } catch {
                                            print("\(error)")
                                        }
                                    } else  {
                                        print("\(String(describing: error))")
                                    }
                                }
                                Gtask.resume()
                                
                            }
                        }
                    }
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
            }
        }
        task.resume()
        

        
        
//        for location in poppinList {
////            geocoder.geocodeAddressString(location) {
////                (placemarks, error) in
////                let placemark = placemarks?.first
////                let lat = placemark?.location?.coordinate.latitude
////                let lon = placemark?.location?.coordinate.longitude
//                let lat = Double(location[0])
//                let lon = Double(location[1])
//                let pin = MKPointAnnotation()
//                pin.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
//                pin.title = "This Works"
//                pins.append(pin)
//        }
        

        
        
        print("pints: \(pins)")
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinIdentifier")
        pin.canShowCallout = true
        return pin
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
        // centerMapOnLocation(location: startingPoint!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    let address = "1 Infinite Loop, Cupertino, CA 95014"

}

