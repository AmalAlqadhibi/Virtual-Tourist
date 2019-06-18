//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Amal Alqadhibi on 18/06/2019.
//  Copyright © 2019 Amal Alqadhibi. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

//,UICollectionViewDataSource, UICollectionViewDelegate
class PhotoAlbumViewController: UIViewController , NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var map: MKMapView!
    var dataController:DataController!
    var latitude:Double!
    var longitude:Double!
    var annotation: Annotation!
    var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findLocations()
         let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "annotation == %@", annotation)

        //        if let resulet = try? dataController.viewContext.fetch(){
        //            photo = result
        //        }
        
        // Do any additional setup after loading the view.
    }
    //Zoom to Annotation that selected by user
    func findLocations() {
        let coords = CLLocationCoordinate2D (latitude: annotation.lat ?? 0.0, longitude: annotation.long ?? 0.0)
        //create annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coords
        self.map.addAnnotation(annotation)
        // zoom to annotation
        let region = MKCoordinateRegion(center: coords, span: MKCoordinateSpan(latitudeDelta: 0.50, longitudeDelta: 0.50))
        map.setRegion(region, animated: true)
    }
    
    
    
    //     func setupFetchedResultsController(){
    //    let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
    //    fetchRequest.sortDescriptors = [
    //    NSSortDescriptor(key: "creationDate", ascending: false)
    //    ]
    //    fetchRequest.predicate = NSPredicate(format: "pin == %@", annotation)
    //
    //    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    //    fetchedResultsController.delegate = self
    //
    //    do {
    //    try fetchedResultsController.performFetch()
    //    if doWeHavePhotos {
    //    updateUI(processing: false)
    //    } else {
    //    buttomButtonTapped(self)
    //    }
    //
    //    } catch {
    //    fatalError("The fetch could not be performd: \(error.localizedDescription)")
    //    }
    //    }
    
    
    
    
    
    //    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    //        return nil
    //    }
    //
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //        return nil
    //    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
