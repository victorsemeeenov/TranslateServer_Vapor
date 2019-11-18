//
//  Token.swift
//  
//
//  Created by Victor on 11.11.2019.
//

import FluentPostgreSQL
import JWT

protocol Token: PostgreSQLModel, Equatable {
    var id: Int? {get set}
    var value: String {get set}
    var user_id: Int {get set}
    var expired_in: Date {get set}
    
    init(id: Int?, value: String, user_id: Int, expired_in: Date)
}

extension Token {
    static func generate(user: User, days: Int) throws -> Self {
        let userJWT = UserJWT(id: user.id!, name: user.name)
        let data = try JWT(payload: userJWT).sign(using: .hs256(key: "secret"))
        let value = String(data: data, encoding: .utf8) ?? ""
        return .init(id: nil, value: value, user_id: userJWT.id, expired_in: Date().addDays(days)!)
    }
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

extension AccessToken: Migration {}

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

extension RefreshToken: Migration {}
