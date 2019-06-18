//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Amal Alqadhibi on 16/06/2019.
//  Copyright © 2019 Amal Alqadhibi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController ,NSFetchedResultsControllerDelegate {
    @IBOutlet weak var travelLocationMap: MKMapView!
    var dataController:DataController!
    var fetchedResultsController: NSFetchedResultsController<Annotation>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        travelLocationMap.delegate = self
        setUpfetchedResultController()
        loadAnnotations()
    }
    
    func setUpfetchedResultController(){
        let fetchRequest: NSFetchRequest<Annotation> = Annotation.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Unable to perform fetch")
        }
    }
    
    @IBAction func addPinAtLongPress(_ sender: UILongPressGestureRecognizer) {
        print("HO")
        let tappedLocation = sender.location(in: travelLocationMap)
        let coord = self.travelLocationMap.convert(tappedLocation, toCoordinateFrom: self.travelLocationMap)
        let mapAnnotation = MKPointAnnotation()
        mapAnnotation.coordinate = coord
        travelLocationMap.addAnnotation(mapAnnotation)
        // Storing create Date and latitude & longitude
        let annotation = Annotation(context: dataController.viewContext)
        annotation.lat = mapAnnotation.coordinate.latitude
        annotation.long = mapAnnotation.coordinate.longitude
        annotation.createDate = Date()
        do {
            try dataController.viewContext.save()
        } catch {
            fatalError("Unable to save the data")
        }
    }
    
    func loadAnnotations(){
        guard let Annotations = fetchedResultsController.fetchedObjects else { return }
        
        for annotation in Annotations {
            let lat = annotation.lat
            let long = annotation.long
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let mapAnnotation = MKPointAnnotation()
            mapAnnotation.coordinate = coordinate
            self.travelLocationMap.addAnnotation(mapAnnotation)
        }
    }
}
// MARK: - MKMapViewDelegate
extension TravelLocationsMapViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: "ShowCollection", sender: self)
    }
}


//        FlickerAPI.getStudentLocations(latitude: 24.6968, longitude: 46.7205, page: 2) { (sucess, photoURL, error) in
//guard error == nil else {
//
//    return
//}
//if sucess{
//
//
//
//}
//}
