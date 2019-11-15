//
//  File.swift
//  
//
//  Created by Victor on 13.11.2019.
//

import Foundation
import FluentPostgreSQL

final class PostgreSQLRepository<T: PostgreSQLModel>: AbstractRepository<T>, TransactionConnectable {
    let db: PostgreSQLDatabase.ConnectionPool
    var currentConnection: DatabaseConnectable?
    
    init(_ db: PostgreSQLDatabase.ConnectionPool) {
           self.db = db
    }
    
    //MARK: Repository
    override func find(_ id: Int) throws -> EventLoopFuture<T?> {
        return db.withConnection { (conn) -> EventLoopFuture<T?> in
            return T.find(id, on: conn)
        }
    }
    
    override func query<P: Encodable>(_ keyPath: KeyPath<T, P>, _ value: P) throws -> EventLoopFuture<[T]> {
        return db.withConnection { (conn) -> EventLoopFuture<[T]> in
            return T.query(on: conn).filter(keyPath, .equal, value).all()
        }
    }
    
    override func first<P>(_ keyPath: KeyPath<T, P>, _ value: P) throws -> EventLoopFuture<T?> where P : Encodable {
        return db.withConnection { (conn) -> EventLoopFuture<T?> in
            return T.query(on: conn).filter(keyPath, .equal, value).first()
        }
    }
    
    override func all() throws -> EventLoopFuture<[T]> {
        return db.withConnection { (conn) -> EventLoopFuture<[T]> in
            return T.query(on: conn).all()
        }
    }
    
    override func create(_ object: T) throws -> EventLoopFuture<T> {
        return db.withConnection { (conn) -> EventLoopFuture<T> in
            return object.create(on: conn)
        }
    }
    
    override func update(_ object: T) throws -> EventLoopFuture<T> {
        return db.withConnection { (conn) -> EventLoopFuture<T> in
            return object.update(on: conn)
        }
    }
    
    override func delete(_ object: T) throws -> EventLoopFuture<Void> {
        return db.withConnection { (conn) -> EventLoopFuture<Void> in
            return object.delete(on: conn)
        }
    }
    
    override func findOperation(_ id: Int) throws -> EventLoopFuture<T?> {
        guard let conn = self.currentConnection else {
            throw DatabaseError.noTransactionConnection
        }
        return T.find(id, on: conn)
    }
    
    override func queryOperation<P>(_ keyPath: KeyPath<T, P>, _ value: P) throws -> EventLoopFuture<[T]> where P : Encodable {
        guard let conn = self.currentConnection else {
            throw DatabaseError.noTransactionConnection
        }
        return T.query(on: conn).filter(keyPath, .equal, value).all()
    }
    
    override func queryFirstOperation<P>(_ keyPath: KeyPath<T, P>, _ value: P) throws -> EventLoopFuture<T?> where P : Encodable {
        guard let conn = self.currentConnection else {
            throw DatabaseError.noTransactionConnection
        }
        return T.query(on: conn).filter(keyPath, .equal, value).first()
    }
    
    override func allOperation() throws -> EventLoopFuture<[T]> {
        guard let conn = self.currentConnection else {
            throw DatabaseError.noTransactionConnection
        }
        return T.query(on: conn).all()
    }
    
    override func createOperation(_ object: T) throws -> EventLoopFuture<T> {
        guard let conn = self.currentConnection else {
            throw DatabaseError.noTransactionConnection
        }
        return object.create(on: conn)
    }
    
    override func updateOperation(_ object: T) throws -> EventLoopFuture<T> {
        guard let conn = self.currentConnection else {
            throw DatabaseError.noTransactionConnection
        }
        return object.update(on: conn)
    }
    
    override func deleteOperation(_ object: T) throws -> EventLoopFuture<Void> {
        guard let conn = self.currentConnection else {
            throw DatabaseError.noTransactionConnection
        }
        return object.delete(on: conn)
    }
}

//MARK: ServiceType conformance
extension PostgreSQLRepository: ServiceType {
    static var serviceSupports: [Any.Type] {
        return [AbstractRepository<T>.self]
    }
    
    static func makeService(for container: Container) throws -> Self {
        return .init(try container.connectionPool(to: .psql))
    }
}
