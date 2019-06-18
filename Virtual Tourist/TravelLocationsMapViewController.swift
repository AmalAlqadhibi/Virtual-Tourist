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
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Annotation")
//
//        // Configure Fetch Request
//        fetchRequest.includesPropertyValues = false
//
//        do {
//            let items = try dataController.viewContext.fetch(fetchRequest) as! [NSManagedObject]
//            print(items.count)
//            for item in items {
//                dataController.viewContext.delete(item)
//            }
//
//            // Save Changes
//            try dataController.viewContext.save()
//
//        } catch {
//            // Error Handling
//            // ...
//        }
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
        // Add an annotation if user's press was ended
        if sender.state == .ended {
        travelLocationMap.addAnnotation(mapAnnotation)
        // Storing create Date and latitude & longitude
        let annotation = Annotation(context: dataController.viewContext)
        annotation.lat = mapAnnotation.coordinate.latitude
        annotation.long = mapAnnotation.coordinate.longitude
        annotation.createDate = Date()
        do {
            try dataController.viewContext.save()
            print("do")
        } catch {
            fatalError("Unable to save the data")
        }
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
        let clickedAnnotation = view.annotation
        let clickedAnnotationLatitude = clickedAnnotation?.coordinate.latitude
        let clickedAnnotationLongitude = clickedAnnotation?.coordinate.longitude
        print("hi from map")
        print(clickedAnnotationLatitude)
        setUpfetchedResultController()
        if let annotations = fetchedResultsController.fetchedObjects {
            print(annotations.count)
            for annotation in annotations {
                if annotation.lat == clickedAnnotationLatitude && annotation.long == clickedAnnotationLongitude {
                    print("waw")
                    performSegue(withIdentifier: "ShowCollection", sender: annotation)
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! PhotoAlbumViewController
        controller.annotation = sender as? Annotation
        controller.dataController = dataController
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
