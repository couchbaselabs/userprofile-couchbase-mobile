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
    func fetchUniversitiesMatchingName( _ name:String,country countryStr:String?, handler:@escaping(_ universities:Universities?, _ error:Error?)->Void)
}

// MARK: UniversityPresentingViewProtocol
// To be implemented by the presenting view
protocol UniversityPresentingViewProtocol:PresentingViewProtocol {
    func updateUIWithUniversityRecords(_ records:Universities?,error:Error?)
}

// MARK: UniversityPresenter
class UniversityPresenter:UniversityPresenterProtocol {
    fileprivate var dbMgr:DatabaseManager = DatabaseManager.shared
    weak var associatedView: UniversityPresentingViewProtocol?
}



extension UniversityPresenter {
    // tag::fetchUniversityRecords[]
    func fetchUniversitiesMatchingName( _ name:String,country countryStr:String?, handler:@escaping(_ universities:Universities?, _ error:Error?)->Void) {
        do {
            // end::fetchUniversityRecords[]
            guard let db = dbMgr.universityDB else {
                fatalError("db is not initialized at this point!")
            }
            
            // tag::buildquery[]
            var whereQueryExpr = Expression.property(UniversityDocumentKeys.name.rawValue)
                .equalTo(Expression.string(name))
            
            if let countryExpr = countryStr {
                let countryQueryExpr = Expression.property(UniversityDocumentKeys.country.rawValue)
                    .equalTo(Expression.string(countryExpr))
                whereQueryExpr = whereQueryExpr.and(countryQueryExpr) // <1>
            }
            
            let universityQuery = QueryBuilder.select(SelectResult.all()) // <2>
                .from(DataSource.database(db)) // <3>
                .where(whereQueryExpr) // <4>
            
            // end::buildquery[]
            
            // tag::runquery[]
            var universities = Universities()
            
            for result in try universityQuery.execute() {
                if let university = result.dictionary(forKey: "universities")?.toDictionary(){
                    var universityRecord = UniversityRecord()
                    
                    print (university)
                }
            }
            // end::runquery[]
            
            self.associatedView?.dataFinishedLoading()
            self.associatedView?.updateUIWithUniversityRecords(universities, error: nil)
            
        }
        catch {
            handler(nil,UserProfileError.DocumentFetchException)
            return
        }
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
