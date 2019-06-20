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
        zoomToLastMapState()
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
        } catch {
            fatalError("unable to save the data")
        }
    }
}
    func zoomToLastMapState() {
        if UserDefaults.standard.value(forKey: "mapState") != nil {
            let lat = UserDefaults.standard.double(forKey: "lastLatitude")
            let long = UserDefaults.standard.double(forKey: "lastLongitude")
            let latSpan = UserDefaults.standard.double(forKey: "lastLatitudeSpan")
            let longSpan = UserDefaults.standard.double(forKey: "lastLongitudeSpan")
            let lastCoordsState = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let region = MKCoordinateRegion(center: lastCoordsState, span: MKCoordinateSpan(latitudeDelta: latSpan, longitudeDelta: longSpan))
            travelLocationMap.setRegion(region, animated: true)
        } else {
            UserDefaults.standard.setValue(true, forKey: "mapState")
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
        setUpfetchedResultController()
        if let annotations = fetchedResultsController.fetchedObjects {
            for annotation in annotations {
                if annotation.lat == clickedAnnotationLatitude && annotation.long == clickedAnnotationLongitude {
                    performSegue(withIdentifier: "ShowCollection", sender: annotation)
                }
            }
        }
    }
 
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        let lastLoggedLatitude = mapView.region.center.latitude
        let lastLoggedLongitude = mapView.region.center.longitude
        let latitudeSpan = mapView.region.span.latitudeDelta
        let longitudeSpan = mapView.region.span.longitudeDelta
        // Storing the area that user zoomed in using user defaults
        UserDefaults.standard.set(lastLoggedLatitude, forKey: "lastLatitude")
        UserDefaults.standard.set(lastLoggedLongitude, forKey: "lastLongitude")
        UserDefaults.standard.set(latitudeSpan, forKey: "lastLatitudeSpan")
        UserDefaults.standard.set(longitudeSpan, forKey: "lastLongitudeSpan")
        UserDefaults.standard.synchronize()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! PhotoAlbumViewController
        controller.annotation = sender as? Annotation
        controller.dataController = dataController
    }
}


