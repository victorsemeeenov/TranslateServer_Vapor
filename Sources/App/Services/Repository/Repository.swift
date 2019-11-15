//
//  Repository.swift
//  
//
//  Created by Victor on 13.11.2019.
//

import Vapor
import FluentPostgreSQL
import Foundation

protocol Repository {
    associatedtype T
    func find(_ id: Int) throws -> Future<T?>
    func query<P: Encodable>(_ keyPath: KeyPath<T, P>, _ value: P) throws -> Future<[T]>
    func first<P: Encodable>(_ keyPath: KeyPath<T, P>, _ value: P) throws -> Future<T?>
    func all() throws -> Future<[T]>
    func create(_ object: T) throws -> Future<T>
    func update(_ object: T) throws -> Future<T>
    func delete(_ object: T) throws -> Future<Void>
}

extension Database {
    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
}

class AbstractRepository<T>: Repository, TransactionOperation {
    func find(_ id: Int) throws -> EventLoopFuture<T?> {
        fatalError("Subclasses need to implement the `find()` method.")
    }
    
    func query<P>(_ keyPath: KeyPath<T, P>, _ value: P) throws -> EventLoopFuture<[T]> where P : Encodable {
        fatalError("Subclasses need to implement the `query()` method.")
    }
    
    func first<P>(_ keyPath: KeyPath<T, P>, _ value: P) throws -> EventLoopFuture<T?> where P : Encodable {
        fatalError("Subclasses need to implement the `first()` method.")
    }
    
    func all() throws -> EventLoopFuture<[T]> {
        fatalError("Subclasses need to implement the `all()` method.")
    }
    
    func create(_ object: T) throws -> EventLoopFuture<T> {
        fatalError("Subclasses need to implement the `create()` method.")
    }
    
    func update(_ object: T) throws -> EventLoopFuture<T> {
        fatalError("Subclasses need to implement the `update()` method.")
    }
    
    func delete(_ object: T) throws -> EventLoopFuture<Void> {
        fatalError("Subclasses need to implement the `delete()` method.")
    }
    
    //MARK: -TransactionOperation
    func findOperation(_ id: Int) throws -> EventLoopFuture<T?> {
        fatalError("Subclasses need to implement the `find()` method.")
    }
    
    func queryOperation<P>(_ keyPath: KeyPath<T, P>, _ value: P) throws -> EventLoopFuture<[T]> where P : Encodable {
        fatalError("Subclasses need to implement the `query()` method.")
    }
    
    func queryFirstOperation<P>(_ keyPath: KeyPath<T, P>, _ value: P) throws -> EventLoopFuture<T?> where P : Encodable {
        fatalError("Subclasses need to implement the `first()` method.")
    }
    
    func allOperation() throws -> EventLoopFuture<[T]> {
        fatalError("Subclasses need to implement the `all()` method.")
    }
    
    func createOperation(_ object: T) throws -> EventLoopFuture<T> {
        fatalError("Subclasses need to implement the `create()` method.")

    }
    
    func updateOperation(_ object: T) throws -> EventLoopFuture<T> {
        fatalError("Subclasses need to implement the `update()` method.")
    }
    
    func deleteOperation(_ object: T) throws -> EventLoopFuture<Void> {
        fatalError("Subclasses need to implement the `delete()` method.")
    }
}

