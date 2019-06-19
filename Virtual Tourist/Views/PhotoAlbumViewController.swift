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
class PhotoAlbumViewController: UIViewController , NSFetchedResultsControllerDelegate,UICollectionViewDataSource , UICollectionViewDelegate {
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var NoPhotoMess: UILabel!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var dataController:DataController!
    var isFirstTime:Bool!
    var annotation: Annotation!
    var photosURL = [URL]()
    var pageNumber = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        findLocations()
        setUpfetchedResultController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        setUpfetchedResultController()
     
    }
    func checkIfItFirsTime(){
        if (fetchedResultsController.fetchedObjects?.count ?? 0) == 0 {
            FlickerAPI.getFlickerPhotosURL(latitude: annotation.lat, longitude: annotation.long , page: pageNumber , completion: handleGetFlickerPhotoResponse(succes:photosURLs:error:))
            isFirstTime = true
        } else {
            self.isFirstTime = false
//            FlickerAPI.getFlickerPhotosURL(latitude: annotation.lat, longitude: annotation.long, page: 2) { (success, photosURLs, error) in
//                guard error == nil else {
//
//                    return
//                }
//                if success {
//                    guard let photosURLs = photosURLs else {
//                        self.NoPhotoMess.isHidden = false
//                        return }
//                    for photoURL in photosURLs {
//                        self.photosURL.append(photoURL)
//
//                    }
//
//                }
//            }
        }
    }
    
    func setUpfetchedResultController(){
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        guard let annotation = annotation else { return }
        let predicate = NSPredicate(format: "annotation == %@", annotation)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
            checkIfItFirsTime()
        
        } catch {
            fatalError("Unable to perform fetch")
        }
        print("LOLO")
        print(fetchedResultsController.fetchedObjects)
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
    func getFlickerPhotos(){
        
    }

    @IBAction func removeImages(_ sender: Any) {
        removeUpdateExistingPhoto()
    }
    
    func removeUpdateExistingPhoto(){
        setUpfetchedResultController()
        if let deleteImages = fetchedResultsController.fetchedObjects {
            for image in deleteImages {
                dataController.viewContext.delete(image)
            }
            do {
                try dataController.viewContext.save()
                
            } catch {
                print("cannot perform the deletion ")
            }
        }
       
        pageNumber += 1
        FlickerAPI.getFlickerPhotosURL(latitude: annotation.lat, longitude: annotation.long, page: pageNumber , completion: handleGetFlickerPhotoResponse(succes:photosURLs:error:))
//        DispatchQueue.main.async {
//            self.collectionview.reloadData()
//        }
    }
    //MARK:- setUp collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFirstTime {
            return photosURL.count
        } else {
            print("We are in second time")
             return  fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }
     
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        if isFirstTime {
             let a = cell.photoLocation.dowloadFromServer(url: photosURL[indexPath.row] )
        } else {
        let photo = self.fetchedResultsController.object(at: indexPath)
       print("Hi there")
        if let  url = photo.url  {
        cell.photoLocation.dowloadFromServer(url: url )
            }}
        return cell
    }
    
    
    
    //MARK:- Response handler
    func handleGetFlickerPhotoResponse(succes:Bool,photosURLs:[URL]?,error: Error?){
        guard error == nil else { return }
        if succes{
//               setUpfetchedResultController()
            guard let photosURLs = photosURLs else {
                self.NoPhotoMess.isHidden = false
                return }
            for photoURL in photosURLs {
                let photo = Photo(context: self.dataController.viewContext)
                photo.url = photoURL
                photo.createDate = Date()
                photo.annotation = self.annotation
                self.photosURL.append(photoURL)
            }
           
            do {
                try self.dataController.viewContext.save()
            } catch {
                print("plaaaaa")
               // fatalError("unable to save the data")
            }
            setUpfetchedResultController()
            DispatchQueue.main.async {
                self.collectionview.reloadData()
            }
        }
    }

}
