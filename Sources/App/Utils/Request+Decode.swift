//
//  File.swift
//  
//
//  Created by Victor on 16.11.2019.
//

import Vapor

extension Request {
    func decode<T: Decodable>(_ Type: T.Type, conn: DatabaseConnectable) -> Future<T> {
        do {
            return try self.content.decode(T.self)
        } catch {
            return .fail(eventLoop: conn.eventLoop, error: error)
        }
    }
}
