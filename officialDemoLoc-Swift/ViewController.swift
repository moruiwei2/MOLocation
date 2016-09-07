//
//  ViewController.swift
//  officialDemoLoc-Swift
//
//  Created by liubo on 7/11/16.
//  Copyright © 2016 AutoNavi. All rights reserved.
//

import UIKit

let defaultLocationTimeout = 6
let defaultReGeocodeTimeout = 3

class ViewController: UIViewController, MAMapViewDelegate, AMapLocationManagerDelegate {
    
    //MARK: - Properties
    
    var mapView: MAMapView!
    var completionBlock: ((location: CLLocation?, regeocode: AMapLocationReGeocode?, error: NSError?) -> Void)!
    lazy var locationManager = AMapLocationManager()
    
    //MARK: - Action Handle
    
    func configLocationManager() {
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        locationManager.pausesLocationUpdatesAutomatically = false
        
        locationManager.allowsBackgroundLocationUpdates = true
        
        locationManager.locationTimeout = defaultLocationTimeout
        
        locationManager.reGeocodeTimeout = defaultReGeocodeTimeout
    }
    
    func cleanUpAction() {
        locationManager.stopUpdatingLocation()
        
        locationManager.delegate = nil
        
        mapView.removeAnnotations(mapView.annotations)
    }
    
    func reGeocodeAction() {
        mapView.removeAnnotations(mapView.annotations)
        
        locationManager.requestLocationWithReGeocode(true, completionBlock: completionBlock)
    }
    
    func locAction() {
        mapView.removeAnnotations(mapView.annotations)
        
        locationManager.requestLocationWithReGeocode(false, completionBlock: completionBlock)
    }
    
    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AMapLocationKit-Demo-Swift"
        view.backgroundColor = UIColor.whiteColor()
        
        initToolBar()
        
        initNavigationBar()
        
        initMapView()
        
        initCompleteBlock()
        
        configLocationManager()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbarHidden = false
    }
    
    //MARK: - Initialization
    
    func initCompleteBlock() {
        
        completionBlock = { [weak self] (location: CLLocation?, regeocode: AMapLocationReGeocode?, error: NSError?) in
            if let error = error {
                NSLog("locError:{%d - %@};", error.code, error.localizedDescription)
                
                if error.code == AMapLocationErrorCode.LocateFailed.rawValue {
                    return;
                }
            }
            
            if let location = location {
                let annotation = MAPointAnnotation()
                annotation.coordinate = location.coordinate
                
                if let regeocode = regeocode {
                    annotation.title = regeocode.formattedAddress
                    annotation.subtitle = "\(regeocode.citycode)-\(regeocode.adcode)-\(location.horizontalAccuracy)m"
                }
                else {
                    annotation.title = String(format: "lat:%.6f;lon:%.6f;", arguments: [location.coordinate.latitude, location.coordinate.longitude])
                    annotation.subtitle = "accuracy:\(location.horizontalAccuracy)m"
                }
                
                self?.addAnnotationsToMapView(annotation)
            }
            
        }
    }
    
    func initMapView() {
        mapView = MAMapView(frame: view.bounds)
        mapView.delegate = self
        
        view.addSubview(mapView)
    }
    
    func addAnnotationsToMapView(annotation: MAAnnotation) {
        mapView.addAnnotation(annotation)
        
        mapView.selectAnnotation(annotation, animated: true)
        mapView.setZoomLevel(15.1, animated: false)
        mapView.setCenterCoordinate(annotation.coordinate, animated: true)
    }
    
    func initToolBar() {
        let flexble = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let reGeocodeItem = UIBarButtonItem(title: "带逆地理定位", style: .Plain, target: self, action: #selector(reGeocodeAction))
        let locItem = UIBarButtonItem(title: "不带逆地理定位", style: .Plain, target: self, action: #selector(locAction))
        
        setToolbarItems([flexble, reGeocodeItem, flexble, locItem, flexble], animated: false)
    }
    
    func initNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clean", style: .Plain, target: self, action: #selector(cleanUpAction))
    }
    
    //MARK: - MAMapVie Delegate
    
    func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation is MAPointAnnotation {
            let pointReuseIndetifier = "pointReuseIndetifier"
            
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pointReuseIndetifier) as? MAPinAnnotationView
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView?.canShowCallout  = true
            annotationView?.animatesDrop    = true
            annotationView?.draggable       = false
            annotationView?.pinColor        = .Purple
            
            return annotationView
        }
        
        return nil
    }

}

