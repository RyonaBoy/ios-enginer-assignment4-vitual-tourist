//
//  ViewControllerPhotos.swift
//  ios-enginer-assignment4-vitual-tourist
//
//  Created by Yu Zhao on 20.06.22.
//

import UIKit
import CoreData

class ViewControllerPhotos: UIViewController{

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    @IBOutlet weak var buttonNewCollection: UIButton!
    var pinCoreData: Pin!
    var longitude: Double?
    var latitude: Double?
    var dataController: DataController!
    var fetchedResultsControllerPin: NSFetchedResultsController<Pin>!
    var fetchedResultsControllerPhotos: NSFetchedResultsController<Photo>!
    var pagesOverall: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupFetchedResultsControllerPin()
        setupFetchedResultsControllerPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsControllerPin = nil
        fetchedResultsControllerPhotos = nil
    }
    
    @IBAction func buttonNewCollectionPressed(_ sender: Any) {
        //disable button
        buttonNewCollection.isEnabled = false
        //delete all photos
        if let fetchedObjects = fetchedResultsControllerPhotos.fetchedObjects{
            print("new collection button to delete photos count \(fetchedObjects.count)")
            for photo in fetchedObjects{
                dataController.persistentContainer.viewContext.delete(photo)
            }
        }
        //download new photos
        FlickrClient.downloadPictureURLs(latitude: latitude ?? 0.0, longitude: longitude ?? 0.0, pages: pagesOverall ?? 1,completion: completionPhotosURLDownload(responseObjectJSON:error:))
        //without this part the app crashes, no idea wy this is needed
        do{
            try fetchedResultsControllerPhotos.performFetch()
            if let fetchedObjects = fetchedResultsControllerPhotos.fetchedObjects{
                print("new collection button fetched photos count \(fetchedObjects.count)")
            }
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func completionPhotosURLDownload(responseObjectJSON: ResponseFlickr?, error: Error?){
        pagesOverall = responseObjectJSON?.photos.pages//set page count and random page range
        
        if let photos = responseObjectJSON?.photos.photo{//fill core data with flickr pictures
            for photo in photos{
                let photoCoreData = Photo(context: self.dataController.persistentContainer.viewContext)
                photoCoreData.url = "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
                photoCoreData.creationDate = Date()//fill core data with creation date
                photoCoreData.pin = self.pinCoreData//fill core data with relationship
                print(photoCoreData.url)
//                let photoURL = URL(string: "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg")!
//                print(photoURL)
//                if let data = try? Data(contentsOf: photoURL){
//                    photoCoreData.image = data//fill core data with image
//                }
                try? self.dataController.persistentContainer.viewContext.save()
            }
        }
        //without this part the app crashes, no idea wy this is needed
        do{
            try fetchedResultsControllerPhotos.performFetch()
            if let fetchedObjects = fetchedResultsControllerPhotos.fetchedObjects{
                print("new collection button fetched photos count \(fetchedObjects.count)")
            }
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        //enable button
        buttonNewCollection.isEnabled = true
    }
    
    fileprivate func setupFetchedResultsControllerPin(){//no idea what happens behind the black box apis
        let fetchRequestPin:NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequestPin.predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", NSNumber(value: latitude ?? 0.0), NSNumber(value: longitude ?? 0.0))
        fetchRequestPin.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: false)]
        fetchedResultsControllerPin = NSFetchedResultsController(fetchRequest: fetchRequestPin, managedObjectContext: dataController.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)//TODO play with cache
        fetchedResultsControllerPin.delegate = self//what the actual fuck happens behind this line in detail?
        do{
            try fetchedResultsControllerPin.performFetch()
            if let fetchedObjects = fetchedResultsControllerPin.fetchedObjects{
                print("fetched pin count \(fetchedObjects.count)")
                self.pinCoreData = fetchedObjects.first
            }
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    fileprivate func setupFetchedResultsControllerPhotos(){//no idea what happens behind the black box apis
        let fetchRequestPhoto:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequestPhoto.predicate = NSPredicate(format: "pin == %@", pinCoreData)
        fetchRequestPhoto.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchedResultsControllerPhotos = NSFetchedResultsController(fetchRequest: fetchRequestPhoto, managedObjectContext: dataController.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)//TODO play with cache
        fetchedResultsControllerPhotos.delegate = self
        do{
            try fetchedResultsControllerPhotos.performFetch()
            if let fetchedObjects = fetchedResultsControllerPhotos.fetchedObjects{
                print("fetched photos count \(fetchedObjects.count)")
                if fetchedObjects.count == 0{//if no photos from core data availble, download photos
                    buttonNewCollection.isEnabled = false//disable button
                    FlickrClient.downloadPictureURLs(latitude: latitude ?? 0.0, longitude: longitude ?? 0.0, pages: pagesOverall ?? 1, completion: completionPhotosURLDownload(responseObjectJSON:error:))
                }
            }
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func setupCollectionView(){//set collection view that each row has 3 photos
        let space: CGFloat = 0.0
        let dimension = (view.frame.size.width - (2*space)) / 3.0
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        layout.itemSize = CGSize(width: dimension, height: dimension)
    }
}
