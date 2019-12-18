//
//  ViewController.swift
//  InnovationTaskMaps
//
//  Created by Thiago Ramos on 16/12/19.
//  Copyright © 2019 Thiago Ramos. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Contacts

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressTextField: UITextField!
    
    let locationManager: CLLocationManager = CLLocationManager()
    var lastLocation: CLLocationCoordinate2D? = nil
    
    var selectedAddress: Address? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        
        if let address = selectedAddress {
            showRoute(address)
        }
    }
        
    @IBAction func tappedShowAddress(_ sender: Any) {
        getPossibleAddressesFromText()
    }
    
    private func showRoute(_ address: Address) {
        let destinationAnnotation        = MKPointAnnotation()
        destinationAnnotation.coordinate = address.placemark.location!.coordinate
        destinationAnnotation.title      = address.name
        self.mapView.addAnnotation(destinationAnnotation)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: lastLocation!))
        request.destination = MKMapItem(placemark: MKPlacemark(placemark: address.placemark))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { (response, error) in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    private func getPossibleAddressesFromText() {
        var addresses: [Address] = []
        CLGeocoder().geocodeAddressString(addressTextField.text!) { (placemarks, error) in
            if error == nil {
                for placemark in placemarks! {
                    addresses.append(self.convertToAddress(placemark: placemark))
                }
                
                self.showAddressesTable(addresses: addresses)
            } else {
                let controller = UIAlertController(title: "Error", message: "Problem trying to fetch addresses from the text", preferredStyle: UIAlertController.Style.alert)
                self.present(controller, animated: true)
            }
        }
    }
    
     private func convertToAddress(placemark: CLPlacemark) -> Address {
         return Address(name: placemark.postalAddress!.street, placemark: placemark, postalAddress: placemark.postalAddress!);
     }
     
    private func showAddressesTable(addresses: [Address]) {
        let addressesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AddressesTableViewController") as! AddressesTableViewController
        addressesVC.addresses = addresses
        addressesVC.selectedAddress = { address in
            self.selectedAddress = address
        }
        self.navigationController?.pushViewController(addressesVC, animated: true)
    }
}

extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        lastLocation = location?.coordinate
        mapView.centerCoordinate = location!.coordinate
        let region = mapView.regionThatFits(MKCoordinateRegion(center: location!.coordinate, latitudinalMeters: 600.0, longitudinalMeters: 600.0))
        mapView.setRegion(region, animated: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .green
        renderer.lineWidth = 5.0
        return renderer
    }
}

struct Address {
    var name: String
    var placemark: CLPlacemark
    var postalAddress: CNPostalAddress
    
    init(name: String, placemark: CLPlacemark, postalAddress: CNPostalAddress) {
        self.name          = name
        self.placemark     = placemark
        self.postalAddress = postalAddress
    }
}

