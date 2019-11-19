//
//  RegisterRequest.swift
//  
//
//  Created by Victor on 12.11.2019.
//

import Vapor

struct RegisterUserRequest: Decodable {
    let username: String
    let email: String
    let password: String
}
