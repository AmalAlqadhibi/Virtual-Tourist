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

class PhotoAlbumViewController: UIViewController , NSFetchedResultsControllerDelegate,UICollectionViewDataSource , UICollectionViewDelegate {
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var NoPhotoMess: UILabel!
    @IBOutlet weak var activeIndicator: UIActivityIndicatorView!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var dataController:DataController!
    var isFirstTime:Bool!
    var annotation: Annotation!
    var photosURL = [URL]()
    var pageNumber = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findLocations()
        self.NoPhotoMess.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setUpfetchedResultController()
        checkIfItFirsTime()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        fetchedResultsController = nil
    }
    func checkIfItFirsTime(){
        setUpUI(isProgressing: true)
        if (fetchedResultsController.fetchedObjects?.count ?? 0) == 0 {
            print("first time")
            FlickerAPI.getFlickerPhotosURL(latitude: annotation.lat, longitude: annotation.long , page: 1 , completion: handleGetFlickerPhotoResponse(succes:photosURLs:error:))
            isFirstTime = true
        } else {
            print("secondtime time")
            setUpUI(isProgressing: false)
            self.isFirstTime = false
        }
    }
    func setUpUI(isProgressing:Bool){
         DispatchQueue.main.async {
        self.collectionview.isUserInteractionEnabled = !isProgressing
        if isProgressing {
        self.activeIndicator.startAnimating()
        } else{
            self.activeIndicator.stopAnimating()
            }
        }
    }
    
    func setUpfetchedResultController(){
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let items = try? dataController.viewContext.fetch(fetchRequest) ?? []
        print(items?.count)
        guard let annotation = annotation else { return }
        let predicate = NSPredicate(format: "annotation == %@", annotation)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
          //  checkIfItFirsTime()
        } catch {
            fatalError("Unable to perform fetch")
        }
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

    @IBAction func removeImages(_ sender: Any) {
        removeUpdateExistingPhoto()
    }
    
    func removeUpdateExistingPhoto(){
        setUpfetchedResultController()
        setUpUI(isProgressing: true)
        if let deleteImages = fetchedResultsController.fetchedObjects {
            for image in deleteImages {
                dataController.viewContext.delete(image)
            }
            do {
                try dataController.viewContext.save()
                DispatchQueue.main.async {
                self.collectionview.reloadData()
                }
            } catch {
                print("cannot perform the deletion ")
            }
        }
        pageNumber += 1
        photosURL.removeAll()
        FlickerAPI.getFlickerPhotosURL(latitude: annotation.lat, longitude: annotation.long, page: pageNumber , completion: handleGetFlickerPhotoResponse(succes:photosURLs:error:))
    }
    
    //MARK:- setUp collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFirstTime {
            return photosURL.count
        } else {
             return  fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        if isFirstTime {
            cell.photoLocation.dowloadFromServer(url: photosURL[indexPath.row] )
        } else {
      let photo = self.fetchedResultsController.object(at: indexPath)
        if let  url = photo.url  {
       cell.photoLocation.dowloadFromServer(url: url )
           }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setUpfetchedResultController()
        if isFirstTime {
            photosURL.remove(at: indexPath.row)
        }
        let photo = self.fetchedResultsController.object(at: indexPath)
         dataController.viewContext.delete(photo)
        
        do {
            try dataController.viewContext.save()
            
        } catch {
            print("cannot perform the deletion ")
        }
        
        setUpfetchedResultController()
        collectionView.reloadData()
    }
    
    //MARK:- Response handler
    func handleGetFlickerPhotoResponse(succes:Bool,photosURLs:[URL]?,error: Error?){
        guard error == nil else { return }
        if succes{
            guard let photosURLs = photosURLs else { return }
            if photosURLs.count == 0 , (fetchedResultsController.fetchedObjects?.count ?? 0) == 0 {
                DispatchQueue.main.async {
                self.NoPhotoMess.isHidden = false
                     }
            }
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
           print("cannot perform the save")
            }
            DispatchQueue.main.async {
                self.setUpUI(isProgressing: false)
                self.collectionview.reloadData()
            }
           
        }
    }

}
