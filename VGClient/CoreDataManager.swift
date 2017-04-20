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

        let context = managedObjectContext
        
        if context.name == nil {
            context.name = "CoreDataManager_Context"
        }
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
    
    /// Remove a AudioRecordItem record
    
    @discardableResult
    func remove(data: AudioData) -> Bool {
        
        var result = true
        
        let context = managedObjectContext
        context.performAndWait {
            do {
                let request = NSFetchRequest<AudioRecordItem>(entityName: "AudioRecordItem")
                request.predicate = NSPredicate(format: "recordDate = %@", data.recordDate as NSDate)
                
                /// fetch
                let result = try context.fetch( request )
                
                /// delete
                result.forEach { context.delete( $0 ) }
                
                /// save
                try context.save()
            } catch {
                print(#function, error.localizedDescription)
                result = false
            }
        }
        
        return result
    }
    
    func asyncRemove(data: AudioData, completion: @escaping (Bool) -> ()) {
        
        let context = managedObjectContext
        context.perform {
            do {
                let request = NSFetchRequest<AudioRecordItem>(entityName: "AudioRecordItem")
                request.predicate = NSPredicate(format: "createDate = %@", data.recordDate as NSDate)
                
                /// fetch
                let result = try context.fetch(request)
                
                /// delete
                result.forEach { context.delete($0) }
                
                /// save
                try context.save()
                
                completion(true)
                
            } catch {
                print(#function, error.localizedDescription)
                completion(false)
            }
        }
    }

    /// insert
    
    func insertEntity<T: NSManagedObject>(_ : T.Type, context: NSManagedObjectContext = CoreDataManager.default.managedObjectContext) -> T {
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "\(T.self)", into: context) as! T
        
        do {
            try context.obtainPermanentIDs(for: [entity])
        } catch {
            print(#function, error)
        }
        
        return entity
    }
    
    /// fetch
    
    func fetch<T: NSManagedObject>() -> [T] {
        var result = [T]()
        let request = NSFetchRequest<T>(entityName: "\(T.self)")
        let context = managedObjectContext
        context.performAndWait {
            do {
                result = try context.fetch(request)
            } catch {
                print(#function, error.localizedDescription)
            }
        }
        return result
    }
    
    func asyncFetch<T: NSManagedObject>(completion: @escaping (Bool, [T]) -> ()) {
        let request = NSFetchRequest<T>(entityName: "\(T.self)")
        let context = managedObjectContext
        context.perform {
            do {
                completion(true, try context.fetch( request ))
            } catch {
                print(#function, error.localizedDescription)
                completion(false, [])
            }
        }
    }
    
    
    
    ///
    
    @discardableResult
    func remove(data: AudioRecordItem) -> Bool {
        
        var res = true
        
        let context = managedObjectContext
        context.performAndWait {
            do {
                let request = NSFetchRequest<AudioRecordItem>(entityName: "AudioRecordItem")
                
                guard let date = data.recordDate else {
                    res = false
                    return
                }
                
                request.predicate = NSPredicate(format: "recordDate = %@", date)
                
                /// fetch
                let result = try context.fetch(request)
                
                /// delete
                result.forEach { context.delete( $0 ) }
                
                /// save
                try context.save()
            } catch {
                res = false
            }
        }
        
        return res
    }
    
}
