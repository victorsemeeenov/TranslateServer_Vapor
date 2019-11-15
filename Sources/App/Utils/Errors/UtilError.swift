//
//  File.swift
//  
//
//  Created by Victor on 15.11.2019.
//

import Vapor

enum UtilError: Debuggable {
    case nilValue
    
    var identifier: String {
        return "Error"
    }
    
    var reason: String {
        switch self {
        case .nilValue:
            return "Значение равно nil"
        }
    }
}

