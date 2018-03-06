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
        
        // First  query for document of specified ID
        var profile = UserRecord.init()
        self.associatedView?.dataStartedLoading()
        if let doc = db.document(withID: self.userProfileDocId) {
     
            profile.email  =  doc.string(forKey: UserRecordKeys.email.rawValue)
            profile.address = doc.string(forKey:UserRecordKeys.address.rawValue)
            profile.imageData = doc.blob(forKey:UserRecordKeys.image.rawValue)?.content
            profile.name =  doc.string(forKey: UserRecordKeys.name.rawValue)
            
        }
        self.associatedView?.dataFinishedLoading()
        self.associatedView?.updateUIWithUserRecord(profile, error: nil)
    }
    
    func setRecordForCurrentUser( _ record:UserRecord?, handler:@escaping(_ error:Error?)->Void) {
        print(record)
        handler(nil)
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
