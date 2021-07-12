//
//  UserPresenter.swift
//  UserProfileDemo
//
//  Created by Priya Rajagopal on 3/1/18.
//  Copyright © 2018 Couchbase Inc. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift


// MARK : typealias
enum UserRecordDocumentKeys:String {
    case type
    case name
    case email
    case address
    case image="imageData"
    case blobMetadata
    case extended
}


// MARK: UserPresenterProtocol
// To be implemented by presenter
protocol UserPresenterProtocol : PresenterProtocol {
    func fetchRecordForCurrentUser( handler:@escaping(_ record:UserRecord?, _ error:Error?)->Void)
    func setRecordForCurrentUser( _ record:UserRecord?, handler:@escaping(_ error:Error?)->Void)
}

// MARK: UserPresentingViewProtocol
// To be implemented by the presenting view
protocol UserPresentingViewProtocol:PresentingViewProtocol {
    func updateUIWithUserRecord(_ record:UserRecord?,error:Error?)
}

// MARK: UserPresenter
class UserPresenter:UserPresenterProtocol {
    fileprivate var dbMgr:DatabaseManager = DatabaseManager.shared
    // tag::userProfileDocId[]
    lazy var userProfileDocId: String = {
        let userId = dbMgr.currentUserCredentials?.user
        return "user::\(userId ?? "")"
    }()
    // end::userProfileDocId[]
    weak var associatedView: UserPresentingViewProtocol?
}



extension UserPresenter {
    // tag::fetchRecordForCurrentUser[]
    func fetchRecordForCurrentUser( handler:@escaping(_ records:UserRecord?, _ error:Error?)->Void) {
        // end::fetchRecordForCurrentUser[]
        
        // tag::docfetch[]
        guard let db = dbMgr.db else {
            fatalError("db is not initialized at this point!")
        }
        
        var profile = UserRecord.init() // <1>
        profile.email = self.dbMgr.currentUserCredentials?.user // <2>
     
        self.associatedView?.dataStartedLoading()
    
        // fetch document corresponding to the user Id
        if let doc = db.document(withID: self.userProfileDocId)  { // <3>
        
            #if CBL3
            // Get JSON String corresponding to the document
            let jsonString = doc.toJSON()
            let jsonData = Data(jsonString.utf8)
            let jsonDecoder = JSONDecoder()
           
            // Map the json string to struct
            profile = try! jsonDecoder.decode(UserRecord.self, from: jsonData)
            // Fetch blob metadata and corresponding blob using metadata
            if let blobMetaString = profile.blobMetadataAsSting {
                let blobMeta = Data(blobMetaString.utf8)
                if let blobJson = try? JSONSerialization.jsonObject(with: blobMeta, options: []) as? [String: Any] {
                    
                    if let blob = try? db.getBlob(properties: blobJson!) {
                            // Get blob from database based on metadata
                            profile.imageData = blob?.content
                        }
                   }
            
            }
            #else
             
            profile.email  =  doc.string(forKey: UserRecordDocumentKeys.email.rawValue)
            profile.address = doc.string(forKey:UserRecordDocumentKeys.address.rawValue)
            profile.name =  doc.string(forKey: UserRecordDocumentKeys.name.rawValue)
            profile.imageData = doc.blob(forKey:UserRecordDocumentKeys.image.rawValue)?.content
         
            #endif
            
        }
        // end::docfetch[]

        self.associatedView?.dataFinishedLoading()
        self.associatedView?.updateUIWithUserRecord(profile, error: nil)
    }
    
    // tag::setRecordForCurrentUser[]
    func setRecordForCurrentUser( _ record:UserRecord?, handler:@escaping(_ error:Error?)->Void) {
    // end::setRecordForCurrentUser[]
        guard let db = dbMgr.db else {
            fatalError("db is not initialized at this point!")
        }
        // tag::doccreate[]
        // This will create a new instance of MutableDocument or will
        // fetch existing one
        // Get mutable version
        #if CBL3
        var mutableDoc = MutableDocument.init(id: self.userProfileDocId)
        #else
        var mutableDoc = MutableDocument.init(id: self.userProfileDocId)
        #endif
        // end::doccreate[]

        // tag::docset[]
        #if CBL3
        // Create blob in database and add metadata to record
        var mutableRecord = record
        if let imageData = mutableRecord?.imageData {
            // Save blob
            let blob = Blob.init(contentType: "image/jpeg", data: imageData)
            try? db.saveBlob(blob: blob)
           // print("BLOB SAVED IS \(blob.toJSON()), ::::: \(blob.properties)")
            // Add blob metadata
            mutableRecord?.blobMetadataAsSting = blob.toJSON()

          }
        
        let jsonEncoder = JSONEncoder()
        if let jsonData = try? jsonEncoder.encode(mutableRecord) {
            let jsonString = String(data: jsonData, encoding: .utf8)!

            try? mutableDoc.setJSON(jsonString)
        }
  
   
        #endif
        // end::docset[]
        
        
        
        // tag::docsave[]
        do {
            // This will create a document if it does not exist and overrite it if it exists
            // Using default concurrency control policy of "writes always win"
            try? db.saveDocument(mutableDoc)
            handler(nil)
        }
        catch {
            handler(error)
        }
        // end::docsave[]
    }
    
}


// MARK: PresenterProtocol
extension UserPresenter:PresenterProtocol {
    func attachPresentingView(_ view:PresentingViewProtocol) {
        self.associatedView = view as? UserPresentingViewProtocol
        
    }
    func detachPresentingView(_ view:PresentingViewProtocol) {
        self.associatedView = nil
    }
}
