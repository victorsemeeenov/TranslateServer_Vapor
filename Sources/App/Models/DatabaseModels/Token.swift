//
//  Token.swift
//  
//
//  Created by Victor on 11.11.2019.
//

import FluentPostgreSQL

protocol Token: PostgreSQLModel {
    var id: Int? {get set}
    var value: String {get set}
    var user_id: Int {get set}
    var expired_in: Date {get set}
}

extension Token {
    var created_at: Date {
        return Date()
    }
}

struct AccessToken: Token {
    static var name: String = "access_token"
    var id: Int?
    var value: String
    var user_id: Int
    var expired_in: Date
}

struct RefreshToken: Token {
    static var name: String = "refresh_token"
    var id: Int?
    var value: String
    var user_id: Int
    var expired_in: Date
}
