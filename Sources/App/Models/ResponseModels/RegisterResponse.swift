//
//  RegisterResponse.swift
//  
//
//  Created by Victor on 16.11.2019.
//

import Vapor

struct AuthResponse: Content {
    let access_token: String
    let refresh_token: String
    let token_type: String
    let expires_in: Int
    
    init(accessToken: String,
         refreshToken: String,
         expiredDate: Date) {
        self.access_token = accessToken
        self.token_type = "bearer"
        self.expires_in = Int(expiredDate.timeIntervalSince(Date()))
        self.refresh_token = refreshToken
    }
}
