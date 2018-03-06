//
//  UserProfile.swift
//  UserProfileDemo
//
//  Created by Priya Rajagopal on 3/6/18.
//  Copyright © 2018 Couchbase Inc. All rights reserved.
//

import Foundation
import UIKit

struct UserRecord {
    var name:String?
    var email:String?
    var address:String?
    var imageData:Data?
    var extended:[[String:Any]]? // future
}
