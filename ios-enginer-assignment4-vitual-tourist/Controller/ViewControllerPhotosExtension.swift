//
//  ViewControllerPhotosExtension.swift
//  ios-enginer-assignment4-vitual-tourist
//
//  Created by Yu Zhao on 24.06.22.
//

import UIKit
import CoreData

extension ViewControllerPhotos: UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {//refactor delegate bs to avoid spaghetti code
    
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
