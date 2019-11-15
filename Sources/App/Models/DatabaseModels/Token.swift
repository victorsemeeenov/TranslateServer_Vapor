//
//  Token.swift
//  
//
//  Created by Victor on 11.11.2019.
//

import FluentPostgreSQL

protocol Token: PostgreSQLModel, Equatable {
    var id: Int? {get set}
    var value: String {get set}
    var user_id: Int {get set}
    var expired_in: Date {get set}
}

//MARK: Equatable
extension Token {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.value == rhs.value
    }
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
    
    init(id: Int? = nil,
         value: String,
         user_id: Int,
         expired_in: Date) {
        self.id = id
        self.value = value
        self.user_id = user_id
        self.expired_in = expired_in
    }
}

struct RefreshToken: Token {
    static var name: String = "refresh_token"
    var id: Int?
    var value: String
    var user_id: Int
    var expired_in: Date
    
    init(id: Int? = nil,
         value: String,
         user_id: Int,
         expired_in: Date) {
        self.id = id
        self.value = value
        self.user_id = user_id
        self.expired_in = expired_in
    }
}
