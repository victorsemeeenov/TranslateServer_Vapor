//
//  User.swift
//  
//
//  Created by Victor on 11.11.2019.
//

import FluentPostgreSQL

struct User: PostgreSQLModel {
    var id: Int?
    var name: String
    var email: String
    var passwordHash: String
}

extension User {
    var accessTokens: Children<User, AccessToken> {
        return children(\.user_id)
    }
    
    var refreshTokens: Children<User, RefreshToken> {
        return children(\.user_id)
    }
}
