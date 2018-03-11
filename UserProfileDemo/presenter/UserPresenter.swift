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
enum UserRecordKeys:String {
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
    func fetchRecordForCurrentUser( handler:@escaping(_ records:UserRecord?, _ error:Error?)->Void) {
        guard let db = dbMgr.db else {
            fatalError("db is not initialized at this point!")
        }
        
        var profile = UserRecord.init()
        self.associatedView?.dataStartedLoading()
        // Fetch user profile document if one exists
        if let doc = db.document(withID: self.userProfileDocId) {
            // Create native object from Document
        
            profile.email  =  doc.string(forKey: UserRecordKeys.email.rawValue)
            profile.address = doc.string(forKey:UserRecordKeys.address.rawValue)
            profile.imageData = doc.blob(forKey:UserRecordKeys.image.rawValue)?.content
            profile.name =  doc.string(forKey: UserRecordKeys.name.rawValue)
            
        }
        self.associatedView?.dataFinishedLoading()
        self.associatedView?.updateUIWithUserRecord(profile, error: nil)
    }
    
    func setRecordForCurrentUser( _ record:UserRecord?, handler:@escaping(_ error:Error?)->Void) {

        guard let db = dbMgr.db else {
            fatalError("db is not initialized at this point!")
        }
        
        // First fetch user profile document if one exists.
        // Get mutable version
        var mutableDoc = MutableDocument.init(id: self.userProfileDocId)
        if let email = record?.email {
            mutableDoc.setString(email, forKey: UserRecordKeys.email.rawValue)
        }
        if let address = record?.address {
            mutableDoc.setString(address, forKey: UserRecordKeys.address.rawValue)
        }
        
        if let name = record?.name {
            mutableDoc.setString(name, forKey: UserRecordKeys.name.rawValue)
        }
        
        if let imageData = record?.imageData {
            let blob = Blob.init(contentType: "image/jpeg", data: imageData)
            mutableDoc.setBlob(blob, forKey: UserRecordKeys.image.rawValue)
        }
    
        do {
            // This will create a document if it does not exist and overrite it if it exists
            // Using default concurrency control policy of "writes always win"
            try? db.saveDocument(mutableDoc)
            handler(nil)
        }
        catch {
            handler(error)
        }
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
