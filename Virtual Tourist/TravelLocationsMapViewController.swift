//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Amal Alqadhibi on 16/06/2019.
//  Copyright © 2019 Amal Alqadhibi. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController {
    @IBOutlet weak var travelLocationMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        travelLocationMap.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func addPinAtLongPress(_ sender: UILongPressGestureRecognizer) {
        print("HO")
        let tappedLocation = sender.location(in: travelLocationMap)
        let coord = self.travelLocationMap.convert(tappedLocation, toCoordinateFrom: self.travelLocationMap)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        travelLocationMap.addAnnotation(annotation)
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

    
}
// MARK: - MKMapViewDelegate
extension TravelLocationsMapViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("ho")
        performSegue(withIdentifier: "ShowCollection", sender: self)
    }
}
