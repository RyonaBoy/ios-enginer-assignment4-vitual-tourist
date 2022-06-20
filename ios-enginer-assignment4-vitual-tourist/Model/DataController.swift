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
            self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            self.backgroundContext.automaticallyMergesChangesFromParent = true
            self.backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            self.persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
            self.autoSaveViewContext(interval: 5)
        }
    }
    
    func autoSaveViewContext(interval: TimeInterval = 30){//autosave stuffs
        print("autosaving")
        guard interval > 0 else{
            print("cannot set negative autosave internal")
            return
        }
        if persistentContainer.viewContext.hasChanges{
            try? persistentContainer.viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval){
            self.autoSaveViewContext(interval: interval)
        }
    }
}
