//
//  DBError.swift
//  LMessenger
//
//  Created by juni on 2/16/25.
//

import Foundation

enum DBError: Error {
    case error(Error)
    case emptyValue
    case invalidatedType
}
