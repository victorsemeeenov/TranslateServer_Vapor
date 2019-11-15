//
//  File.swift
//  
//
//  Created by Victor on 15.11.2019.
//

import Vapor

struct LoginUserRequest: Content {
    let username: String
    let password: String
}
