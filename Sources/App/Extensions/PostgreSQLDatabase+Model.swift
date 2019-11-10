//
//  File.swift
//  
//
//  Created by Victor on 09.11.2019.
//

import Foundation
import PostgreSQL
import SwiftyJSON

extension PostgreSQLDatabase {
    convenience init?(fromConfig filename: String, transportConfig: PostgreSQLConnection.TransportConfig = .cleartext) throws {
        do {
            guard let string = try String.dataFromFile(filename) else {return nil}
            let config = try JSONDecoder().decode(DatabaseConfig.self, from: string)
            self.init(config: PostgreSQLDatabaseConfig(hostname: config.hostname, port: config.port, username: config.username, database: config.database, password: config.password, transport: transportConfig))
        } catch {
            throw error
        }
    }
}

