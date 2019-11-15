//
//  File.swift
//  
//
//  Created by Victor on 14.11.2019.
//

import Vapor

enum DatabaseError: Debuggable {
    case noTransactionConnection
    case noDatabaseRepository
    
    var identifier: String {
        return "Error"
    }
    
    var reason: String {
        switch self {
        case .noTransactionConnection:
            return "При транзакции отсутсвует соединение с БД"
        case .noDatabaseRepository:
            return "Это не репозиторий БД"
        }
    }
}
