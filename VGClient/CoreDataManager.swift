//
//  CoreDataManager.swift
//  VGClient
//
//  Created by jie on 2017/2/13.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import Foundation
import CoreData


class CoreDataManager: NSObject {
    
    /// Shared instance
    static let `default`: CoreDataManager = CoreDataManager()
    
    private override init() { }
    
    /// init core data stack and folder
    func load() {
        
        initDBDirectory()

        managedObjectContext.name = "CoreDataManager_Context"
    }
    
    /// create specific folder
    
    private let dbFolderName = "vg_database"
    
    var dbDirectory: URL {
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        return documentDirectory.appendingPathComponent(dbFolderName)
    }
    
    func initDBDirectory() {
        let directory = dbDirectory
        
        if FileManager.default.fileExists(atPath: directory.path) {
            return
        }
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(#function, error.localizedDescription)
        }
    }
    
    /// Core data stack
    
    let audioDBName = "VGClient_database_audio.sqlite"

    var storeURL: URL {
        return dbDirectory.appendingPathComponent(audioDBName)
    }
    
    var modelURL: URL {
        if let url =  Bundle.main.url(forResource: "VGClient", withExtension: "momd") {
            return url
        }
        fatalError("CoreDataManager : fetch modelURL error")
    }
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        guard let model = NSManagedObjectModel(contentsOf: self.modelURL) else {
            fatalError("CoreDataManager : managedObjectModel error")
        }
        return model
    }()

    /** options
     * 0. 禁用数据库WAL日志记录模式: NSSQLitePragmasOption = ["journal_mode":"DELETE"]
     * 1. 低版本存储区迁移到新模型: NSMigratePersistentStoresAutomaticallyOption = true
     * 2. 轻量级的迁移方式: NSInferMappingModelAutomaticallyOption = true
     * 3. 默认的迁移方式: NSInferMappingModelAutomaticallyOption = false
     */
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let model = self.managedObjectModel
        let store = self.storeURL
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: store,
                                               options: [NSMigratePersistentStoresAutomaticallyOption:true,
                                                         NSInferMappingModelAutomaticallyOption:true])
        } catch {
            print("CoreDataManager : creating or loading persistentStoreCoordinator error<\(error.localizedDescription)>")
        }
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.undoManager = UndoManager()
        
        return managedObjectContext
    }()
    
    func saveContext() {
        print(#function)
        let context = self.managedObjectContext
        
        context.perform {
            if !context.hasChanges {
                return
            }
            do {
                try context.save()
            } catch {
                print("\ncontext saved failed!", context)
            }
        }
    }
    
    
    func append(data: AudioData) {
        
        let item = CoreDataManager.default.insertEntity(AudioRecordItem.self)
        item.createDate = data.recordDate as NSDate
        item.duration = data.duration
        item.filename = data.filename
        
        saveContext()
    }
    
    func remove(data: AudioData) {
        
        var result = [AudioRecordItem]()
        
        let request = NSFetchRequest<AudioRecordItem>(entityName: "AudioRecordItem")
        request.predicate = NSPredicate(format: "createDate = %@", data.recordDate as NSDate)

        let context = CoreDataManager.default.managedObjectContext
        
        context.performAndWait {
            do {
                result = try context.fetch( request )
            } catch {
                print(#function, error.localizedDescription)
            }
        }
        
        result.forEach { item in
            
            context.performAndWait { context.delete(item) }
        }
        
        saveContext()
    }
    

    func insertEntity<T: NSManagedObject>(_ : T.Type, context: NSManagedObjectContext = CoreDataManager.default.managedObjectContext) -> T {
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "\(T.self)",
            into: context) as! T
        
        do {
            try context.obtainPermanentIDs(for: [entity])
        } catch {
            print(#function, error)
        }
        
        return entity
    }
    
    
}
