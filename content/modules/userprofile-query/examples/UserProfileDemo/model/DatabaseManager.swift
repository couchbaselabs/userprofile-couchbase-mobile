//
//  DatabaseManager.swift
//  UserProfileDemo
//
//  Created by Priya Rajagopal on 2/19/18.
//  Copyright © 2018 Couchbase Inc. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

class DatabaseManager {
    
    // public
    var db:Database? {
        get {
            return _db
        }
    }
    
    var universityDB:Database? {
        get {
            return _universitydb
        }
    }
    var dbChangeListenerToken:ListenerToken?
    
    
    // For demo purposes only. In prod apps, credentials must be stored in keychain
    public fileprivate(set) var currentUserCredentials:(user:String,password:String)?
    
    var lastError:Error?

    // db name
    fileprivate let kDBName:String = "userprofile"
    fileprivate let kUniversityDBName:String = "universities"
    fileprivate let kPrebuiltDBFolder:String = "prebuilt"
    
    fileprivate var _db:Database?
    fileprivate var _universitydb:Database?
    
    fileprivate var _applicationDocumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    
    fileprivate var _applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
    
    static let shared:DatabaseManager = {
        
        let instance = DatabaseManager()
        instance.initialize()
        return instance
    }()
    
    func initialize() {
        //  enableCrazyLevelLogging()
    }
    // Don't allow instantiation . Enforce singleton
    private init() {
        
    }
    
    deinit {
        // Stop observing changes to the database that affect the query
        do {
            try self._db?.close()
        }
        catch  {
            
        }
    }
    
}

// MARK: Public
extension DatabaseManager {
    // tag::openOrCreateDatabaseForUser[]
    func openOrCreateDatabaseForUser(_ user:String, password:String, handler:(_ error:Error?)->Void) {
    // end::openOrCreateDatabaseForUser[]
        do {
            // tag::dbconfig[]
            var options = DatabaseConfiguration()
            guard let defaultDBPath = _applicationSupportDirectory else {
                fatalError("Could not open Application Support Directory for app!")
                return
            }
            // Create a folder for the logged in user if one does not exist
            let userFolderUrl = defaultDBPath.appendingPathComponent(user, isDirectory: true)
            let userFolderPath = userFolderUrl.path
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: userFolderPath) {
                try fileManager.createDirectory(atPath: userFolderPath,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
                
            }
            // Set the folder path for the CBLite DB
            options.directory = userFolderPath
            // end::dbconfig[]
   
            print("Will open/create DB  at path \(userFolderPath)")
            // tag::dbcreate[]
            // Create a new DB or get handle to existing DB at specified path
            _db = try Database(name: kDBName, config: options)
            
            // end::dbcreate[]
            
            // register for DB change notifications
            self.registerForDatabaseChanges()
            
            currentUserCredentials = (user,password)
            handler(nil)
        }catch {
            
            lastError = error
            handler(lastError)
        }
    }
  
    // tag::closeDatabaseForCurrentUser[]
    func closeDatabaseForCurrentUser() -> Bool {
    // end::closeDatabaseForCurrentUser[]
        do {
            print(#function)
            // Get handle to DB  specified path
            if let db = self.db {
                deregisterForDatabaseChanges()
                // tag::dbclose[]
                try db.close()
                // end::dbclose[]
                _db = nil
            }
            
            return true
        }
        catch {
            return false
        }
    }
    
    // tag::registerForDatabaseChanges[]
    fileprivate func registerForDatabaseChanges() {
        // end::registerForDatabaseChanges[]
        
        // tag::adddbchangelistener[]
        // Add database change listener
        dbChangeListenerToken = db?.addChangeListener({ [weak self](change) in
            guard let `self` = self else {
                return
            }
            for docId in change.documentIDs   {
                if let docString = docId as? String {
                    let doc = self._db?.document(withID: docString)
                    if doc == nil {
                        print("Document was deleted")
                    }
                    else {
                        print("Document was added/updated")
                    }
                }
            }
        })
        // end::adddbchangelistener[]
    }
    
    // tag::deregisterForDatabaseChanges[]
    fileprivate func deregisterForDatabaseChanges() {
        // end::deregisterForDatabaseChanges[]
        
        // tag::removedbchangelistener[]
        // Add database change listener
        if let dbChangeListenerToken = self.dbChangeListenerToken {
            db?.removeChangeListener(withToken: dbChangeListenerToken)
        }
   
        // end::removedbchangelistener[]
    }
}

// MARK: Prebuilt University Database
extension DatabaseManager {
    
    // tag::openPrebuiltDatabase[]
    func openPrebuiltDatabase(handler:(_ error:Error?)->Void) {
        // end::openPrebuiltDatabase[]
        do {
            // tag::prebuiltdbconfig[]
            var options = DatabaseConfiguration()
            guard let universityFolderUrl = _applicationSupportDirectory else {
                fatalError("Could not open Application Support Directory for app!")
                return
            }
            let universityFolderPath = universityFolderUrl.path
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: universityFolderPath) {
                try fileManager.createDirectory(atPath: universityFolderPath,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
                
            }
            // Set the folder path for the CBLite DB
            options.directory = universityFolderPath
            // end::prebuiltdbconfig[]
            
            print("Will open Prebuilt DB  at path \(universityFolderPath)")
            // tag::prebuiltdbopen[]
            // Load the prebuilt "universities" database if it does not exist as the specified folder
            if Database.exists(withName: kUniversityDBName, inDirectory: universityFolderPath) == false {
                // Load prebuilt database from App Bundle and copy over to Applications support path
                if let prebuiltPath = Bundle.main.path(forResource: kUniversityDBName, ofType: "cblite2") {
                    try Database.copy(fromPath: prebuiltPath, toDatabase: "\(kUniversityDBName)", withConfig: options)
                    
                }
                // Get handle to DB  specified path
                _universitydb = try Database(name: kUniversityDBName, config: options)
                
                // Create indexes to facilitate queries
                try createUniversityDatabaseIndexes()
                
            }
            else
            {
                // Gets handle to existing DB at specified path
                _universitydb = try Database(name: kUniversityDBName, config: options)
                
            }
            
            // end::prebuiltdbopen[]
            
            handler(nil)
        }catch {
            
            lastError = error
            handler(lastError)
        }
    }
    
    // tag::closePrebuiltDatabase[]
    func closePrebuiltDatabase() -> Bool {
        // end::closePrebuiltDatabase[]
        do {
            print(#function)
            // Get handle to DB  specified path
            if let universitydb = self.universityDB {
                // tag::dbclose[]
                try universitydb.close()
                // end::dbclose[]
                _universitydb = nil
            }
            
            return true
        }
        catch {
            return false
        }
    }
    
    // tag::createUniversityDatabaseIndexes[]
    fileprivate func createUniversityDatabaseIndexes()throws {
        // For searches on type property
        try _universitydb?.createIndex(IndexBuilder.valueIndex(items:  ValueIndexItem.expression(Expression.property("name")),ValueIndexItem.expression(Expression.property("location"))), withName: "NameLocationIndex")
     
    }
    // end::createUniversityDatabaseIndexes[]

}

// MARK: Utils
extension DatabaseManager {
    
    fileprivate func enableCrazyLevelLogging() {
        Database.setLogLevel(.verbose, domain: .query)
    }
    
}

