//
//  File.swift
//  
//
//  Created by Victor on 15.11.2019.
//

import FluentPostgreSQL

extension DatabaseConnectable {
    func transact<T>(closure: @escaping (PostgreSQLDatabase.Connection) throws -> Future<T>) -> Future<T> {
        return transaction(on: .psql, closure)
    }
}
