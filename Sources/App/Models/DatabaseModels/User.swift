//
//  User.swift
//  
//
//  Created by Victor on 11.11.2019.
//

import FluentPostgreSQL
import JWT

struct User: PostgreSQLModel {
    var id: Int?
    var name: String
    var email: String
    var passwordHash: String
    
    var accessTokens: Children<User, AccessToken> {
        return children(\.user_id)
    }
    
    var refreshTokens: Children<User, RefreshToken> {
        return children(\.user_id)
    }
    
    init(name: String,
         email: String,
         passwordHash: String) {
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
}

extension User: Migration {}

struct UserJWT: JWTPayload {
    var id: Int
    var name: String
    var date: Date
    
    init(id: Int,
         name: String) {
        self.id = id
        self.name = name
        self.date = Date()
    }
    
    func verify(using signer: JWTSigner) throws {}
}
