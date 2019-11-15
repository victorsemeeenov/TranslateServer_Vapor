//
//  File.swift
//  
//
//  Created by Victor on 13.11.2019.
//

import Vapor
import FluentPostgreSQL

extension Services {
    private mutating func registerPostgreeSqlRepository<Model: PostgreSQLModel>(_ Type: Model) {
        self.register(PostgreSQLRepository<Model>.self)
    }
}
