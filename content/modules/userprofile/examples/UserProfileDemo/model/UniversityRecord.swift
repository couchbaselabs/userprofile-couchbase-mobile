//
//  UniversityRecord.swift
//  UserProfileDemo
//
//  Created by Priya Rajagopal on 5/2/18.
//  Copyright © 2018 Couchbase Inc. All rights reserved.
//

import Foundation

// tag::universityrecord[]
typealias Universities = [UniversityRecord]
// Native object
#if CBL3
struct UniversityRecord : CustomStringConvertible, Codable{
    
    var alphaTwoCode:String?
    var country:String?
    var domains:[String]?
    var name:String?
    var webPages:[String]?
    
    var description: String {
        return "name = \(String(describing: name)), country = \(String(describing: country)), domains = \(String(describing: domains)), webPages = \(webPages), alphaTwoCode = \(String(describing: alphaTwoCode)) "
    }
    
    private enum CodingKeys: String, CodingKey {
        case alphaTwoCode = "alpha_two_code"
        case name = "name"
        case country = "country"
        case domains = "domains"
        case webPages = "web_pages"
      }
    
}
#else
struct UniversityRecord : CustomStringConvertible{
    
    var alphaTwoCode:String?
    var country:String?
    var domains:[String]?
    var name:String?
    var webPages:[String]?
    
    var description: String {
        return "name = \(String(describing: name)), country = \(String(describing: country)), domains = \(String(describing: domains)), webPages = \(webPages), alphaTwoCode = \(String(describing: alphaTwoCode)) "
    }
    
}
#endif
// end::universityrecord[]
