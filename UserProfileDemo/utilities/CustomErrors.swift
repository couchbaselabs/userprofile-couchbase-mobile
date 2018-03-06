//
//  CustomErrors.swift
//  UserProfileDemo
//
//  Created by Priya Rajagopal on 2/19/18.
//  Copyright © 2018 Couchbase Inc. All rights reserved.
//

import Foundation
enum UserProfileError:Error {
    case DatabaseNotInitialized
    case UserNotFound
    case RemoteDatabaseNotReachable
    case DataParseError
    case UserCredentialsNotProvided
    case DocumentFetchException
    case ImageProcessingFailure
    case ImageTooBig
}

