//
//  File.swift
//  
//
//  Created by Victor on 14.11.2019.
//

import FluentPostgreSQL
import Vapor

final class PostgreeSQLTransactionProcess: TransactionProcess {
    let connection: DatabaseConnectable?
    
    init(with connection: DatabaseConnectable?) {
        self.connection = connection
    }
    
    func addOperation<Repository, U>(to repository: Repository, _ transactionOperation: (Repository) throws -> EventLoopFuture<U>) throws -> EventLoopFuture<U> where Repository : TransactionOperation {
        guard let postgreeRepo = repository as? PostgreSQLRepository<User> else {
            throw DatabaseError.noDatabaseRepository
        }
        postgreeRepo.currentConnection = connection
        do {
            return try transactionOperation(repository).map { (value) -> U in
                return value
            }
        } catch {
            throw error
        }
    }
}

final class PostgreeSQLTransaction: Transaction {    
    let db: PostgreSQLDatabase.ConnectionPool
    
    init(_ db: PostgreSQLDatabase.ConnectionPool) {
           self.db = db
    }
    
    func transact<T>(_ transactionBlock: (TransactionProcess) throws -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        db.withConnection { (conn) -> EventLoopFuture<T> in
            conn.transaction(on: .psql) { (conn) -> EventLoopFuture<T> in
                do {
                    return try transactionBlock(PostgreeSQLTransactionProcess(with: conn))
                } catch {
                    throw error
                }
            }
        }
    }
}

extension PostgreeSQLTransaction: ServiceType {
    static var serviceSupports: [Any.Type] {
        return [Transaction.self]
    }
    
    static func makeService(for container: Container) throws -> Self {
        return try .init(container.connectionPool(to: .psql))
    }
}

