//
//  UniversityPresenter.swift
//  UserProfileDemo
//
//  Created by Priya Rajagopal on 5/2/18.
//  Copyright © 2018 Couchbase Inc. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

// MARK : keys in the JSON Document
enum UniversityDocumentKeys:String {
    case alphaTwoCode = "alpha_two_code"
    case country
    case domains
    case name
    case webPages = "web_pages"
    
}

// MARK: UniversityPresenterProtocol
// To be implemented by presenter
protocol UniversityPresenterProtocol : PresenterProtocol {
    func fetchUniversitiesMatchingDescription( _ descriptionStr:String?,location locationStr:String, handler:@escaping(_ universities:Universities?, _ error:Error?)->Void)
}

// MARK: UniversityPresentingViewProtocol
// To be implemented by the presenting view
protocol UniversityPresentingViewProtocol:PresentingViewProtocol {
    func updateUIWithUniversityRecords(_ records:Universities?,error:Error?)
}

// MARK: UniversityPresenter
class UniversityPresenter:UniversityPresenterProtocol {
    fileprivate var universityQuery: Query?
    fileprivate var dbMgr:DatabaseManager = DatabaseManager.shared
    
    weak var associatedView: UniversityPresentingViewProtocol?
}



extension UniversityPresenter {
    // tag::fetchUniversityRecords[]
    func fetchUniversitiesMatchingDescription( _ descriptionStr:String?,location locationStr:String, handler:@escaping(_ universities:Universities?, _ error:Error?)->Void) {
        // end::fetchUniversityRecords[]
        guard let db = dbMgr.db else {
            fatalError("db is not initialized at this point!")
        }
        
        // Create a reference to the university collection
        let universityRef = db.collection("university")
        
        // Can only do exact match. No wildcard or any pattern matching.
        // No search either (unless I configure ES etc)
        
        let query = universityRef.whereField("country", isEqualTo:locationStr)
        
        // No OR operation either
        if let descriptionStr = descriptionStr {
            universityRef.whereField("name", isEqualTo:descriptionStr)
        }
        
        query.getDocuments { (snapshot, error) in
            
            guard let snapshotVal = snapshot else {
                handler([],nil)
                return
            }
            var universities = Universities()
            for   document in snapshotVal.documents {
                print("Document data: \(document.data())")
                var university = UniversityRecord()
                let docData = document.data()
                university.name = docData[ UniversityDocumentKeys.name.rawValue] as? String
                university.country  =  docData[UniversityDocumentKeys.country.rawValue] as? String
                university.webPages  =  docData[UniversityDocumentKeys.webPages.rawValue] as? [String]
                
                universities.append(university)
            }
            
            self.associatedView?.dataFinishedLoading()
            self.associatedView?.updateUIWithUniversityRecords(universities, error: nil)
            
        }
        
        // tag: docquery[]
        
        handler([],nil)
        // end::docquery[]
        
    }
  
}


// MARK: PresenterProtocol
extension UniversityPresenter:PresenterProtocol {
    func attachPresentingView(_ view:PresentingViewProtocol) {
        self.associatedView = view as? UniversityPresentingViewProtocol
        
    }
    func detachPresentingView(_ view:PresentingViewProtocol) {
        self.associatedView = nil
    }
}
