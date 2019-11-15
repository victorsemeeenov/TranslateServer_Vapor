//
//  RegisterRequest.swift
//  
//
//  Created by Victor on 12.11.2019.
//

import Vapor

struct RegisterUserRequest: Content {
    let username: String
    let email: String
    let password: String
}
