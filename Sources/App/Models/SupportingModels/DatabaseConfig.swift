//
//  DatabaseConfig.swift
//  
//
//  Created by Victor on 10.11.2019.
//

import Foundation
import SwiftyJSON

struct DatabaseConfig: Decodable {
    let username: String
    let database: String
    let password: String?
    let hostname: String
    let port: Int
}
