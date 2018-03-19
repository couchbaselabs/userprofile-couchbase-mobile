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
    case image
    case name
    case email
    case address
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
    fileprivate var userQuery: Query?
    fileprivate var dbMgr:DatabaseManager = DatabaseManager.shared
    
    lazy var userProfileDocId: String = {
        let userId = dbMgr.currentUserCredentials?.user
        return "user::\(userId)"
    }()
    weak var associatedView: UserPresentingViewProtocol?
}



extension UserPresenter {
    // tag::fetchRecordForCurrentUser[]
    func fetchRecordForCurrentUser( handler:@escaping(_ records:UserRecord?, _ error:Error?)->Void) {
    // end::fetchRecordForCurrentUser[]
        guard let db = dbMgr.db else {
            fatalError("db is not initialized at this point!")
        }
        
        var profile = UserRecord.init()
        self.associatedView?.dataStartedLoading()
        // Fetch user profile document if one exists
        // tag::docfetch[]
        
        if let doc = db.document(withID: self.userProfileDocId) {
            // Create native object from Document
            
            profile.email  =  doc.string(forKey: UserRecordDocumentKeys.email.rawValue)
            profile.address = doc.string(forKey:UserRecordDocumentKeys.address.rawValue)
            // tag::blobfetch[]
            profile.imageData = doc.blob(forKey:UserRecordDocumentKeys.image.rawValue)?.content
            // end::blobfetch[]
            profile.name =  doc.string(forKey: UserRecordDocumentKeys.name.rawValue)
            
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
        // First fetch user profile document if one exists.
        // Get mutable version
        var mutableDoc = MutableDocument.init(id: self.userProfileDocId)
        // end::doccreate[]

        // tag::docset[]
        if let email = record?.email {
            mutableDoc.setString(email, forKey: UserRecordDocumentKeys.email.rawValue)
        }
        if let address = record?.address {
            mutableDoc.setString(address, forKey: UserRecordDocumentKeys.address.rawValue)
        }
        
        if let name = record?.name {
            mutableDoc.setString(name, forKey: UserRecordDocumentKeys.name.rawValue)
        }
        // end::docset[]
        // tag::blobset[]
        if let imageData = record?.imageData {
            let blob = Blob.init(contentType: "image/jpeg", data: imageData)
            mutableDoc.setBlob(blob, forKey: UserRecordDocumentKeys.image.rawValue)
        }
        // end::blobset[]
        
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
