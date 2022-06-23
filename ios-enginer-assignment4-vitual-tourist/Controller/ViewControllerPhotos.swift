//
//  ViewControllerPhotos.swift
//  ios-enginer-assignment4-vitual-tourist
//
//  Created by Yu Zhao on 20.06.22.
//

import UIKit
import CoreData

class ViewControllerPhotos: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    @IBOutlet weak var buttonNewCollection: UIButton!
    var pinCoreData: Pin!
    var longitude: Double?
    var latitude: Double?
    var dataController: DataController!
    var fetchedResultsControllerPin: NSFetchedResultsController<Pin>!
    var fetchedResultsControllerPhotos: NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsControllerPin()
        setupFetchedResultsControllerPhotos()
        setupCollectionViewLayout()
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
        if let fetchedObjects = fetchedResultsControllerPhotos.fetchedObjects{
            print("fetched photos count \(fetchedObjects.count)")
            for photo in fetchedObjects{
                dataController.persistentContainer.viewContext.delete(photo)
            }
        }
        
        let requestBodyJson = RequestFlickr(api_key: FlickrClient.Auth.keyAPI, lat: latitude ?? 0.0, lon: longitude ?? 0.0)
        FlickrClient.taskForPOSTRequest(url: FlickrClient.Endpoints.searchPhotos(latitude: "\(latitude ?? 0.0)", longitude: "\(longitude ?? 0.0)").url, responseType: ResponseFlickr.self, body: requestBodyJson){ responseObjectJSON, error in
            if let photos = responseObjectJSON?.photos.photo{
                for photo in photos{
                    let photoCoreData = Photo(context: self.dataController.persistentContainer.viewContext)
                    let photoURL = URL(string: "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg")!
                    print(photoURL)
                    if let data = try? Data(contentsOf: photoURL){
                        photoCoreData.image = data
                        photoCoreData.creationDate = Date()
//                        photoCoreData.pin = self.pinCoreData
                    }
                    try? self.dataController.persistentContainer.viewContext.save()
                }
                
                self.collectionView.reloadData()
            }
        }
    }
    
    fileprivate func setupFetchedResultsControllerPin(){//fuck this shit
        let fetchRequestPin:NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequestPin.predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", NSNumber(value: latitude ?? 0.0), NSNumber(value: longitude ?? 0.0))
        fetchRequestPin.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: false)]
        fetchedResultsControllerPin = NSFetchedResultsController(fetchRequest: fetchRequestPin, managedObjectContext: dataController.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsControllerPin.delegate = self//what does this line do, is it needed?
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
    
    fileprivate func setupFetchedResultsControllerPhotos(){//fuck this shit
        let fetchRequestPhoto:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequestPhoto.predicate = NSPredicate(format: "pin == %@", pinCoreData)
        fetchRequestPhoto.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchedResultsControllerPhotos = NSFetchedResultsController(fetchRequest: fetchRequestPhoto, managedObjectContext: dataController.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: "photos")
        fetchedResultsControllerPhotos.delegate = self
        do{
            try fetchedResultsControllerPhotos.performFetch()
            if let fetchedObjects = fetchedResultsControllerPhotos.fetchedObjects{
                print("fetched photos count \(fetchedObjects.count)")
            }
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func setupCollectionViewLayout(){
        let space: CGFloat = 0.0
        let dimension = (view.frame.size.width - (2*space)) / 3.0
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        layout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsControllerPhotos.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsControllerPhotos.sections?[section].numberOfObjects ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        let photo = fetchedResultsControllerPhotos.object(at: indexPath)
        cell.imageView.image = UIImage(data: photo.image!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsControllerPhotos.object(at: indexPath)
        dataController.persistentContainer.viewContext.delete(photoToDelete)
        try? dataController.persistentContainer.viewContext.save()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            break
        case .update:
            collectionView.reloadItems(at: [indexPath!])
            break
        case .move:
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
            break
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            collectionView.insertSections(indexSet)
            break
        case .delete:
            collectionView.deleteSections(indexSet)
        case .move, .update:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        default:
            break
        }
    }
}
