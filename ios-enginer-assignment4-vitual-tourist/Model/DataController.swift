//
//  DataController.swift
//  assignment4
//
//  Created by Yu Zhao on 18.06.22.
//

import Foundation
import CoreData

class DataController{
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext{ return persistentContainer.viewContext }
    let backgroundContext: NSManagedObjectContext!    //some concurrency bullshit, no idea how to use

    init(modelName: String){
        persistentContainer = NSPersistentContainer(name: modelName)
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func load(){
        persistentContainer.loadPersistentStores{storeDescription, error in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            //no idea what these bullshits do, copy pasted from mooskine
            self.viewContext.automaticallyMergesChangesFromParent = true
            self.backgroundContext.automaticallyMergesChangesFromParent = true
            self.backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            self.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        }
    }
}
