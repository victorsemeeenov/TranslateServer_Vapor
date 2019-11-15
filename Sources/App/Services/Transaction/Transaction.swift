//
//  Transaction.swift
//  
//
//  Created by Victor on 14.11.2019.
//

import Vapor

protocol TransactionProcess {
    func addOperation<Repository: TransactionOperation, U>(to repository: Repository,
                                                                _ transactionOperation: (Repository) throws -> Future<U>) throws -> Future<U>
}

protocol Transaction {
    func transact<T>(_ transactionBlock: (TransactionProcess) throws -> Future<T>) -> Future<T>
}

protocol TransactionConnectable {
    var currentConnection: DatabaseConnectable? {get set}
}

protocol TransactionOperation {
    associatedtype T
    func findOperation(_ id: Int) throws -> Future<T?>
    func queryOperation<P: Encodable>(_ keyPath: KeyPath<T, P>, _ value: P) throws -> Future<[T]>
    func queryFirstOperation<P: Encodable>(_ keyPath: KeyPath<T, P>, _ value: P) throws -> Future<T?>
    func allOperation() throws -> Future<[T]>
    func createOperation(_ object: T) throws -> Future<T>
    func updateOperation(_ object: T) throws -> Future<T>
    func deleteOperation(_ object: T) throws -> Future<Void>
}
