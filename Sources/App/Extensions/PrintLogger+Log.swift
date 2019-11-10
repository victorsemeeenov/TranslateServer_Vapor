//
//  PrintLogger+Log.swift
//  
//
//  Created by Victor on 10.11.2019.
//

import Foundation
import Logging

extension PrintLogger {
    enum LogType {
        case error(Error)
        case warning(String)
        case message(String)
    }
    
    func log(_ type: LogType, file: String, function: String, line: UInt, column: UInt) {
        switch type {
        case .error(let error):
            self.log(error.localizedDescription, at: .error, file: file, function: function, line: line, column: column)
        case .message(let message):
            self.log(message, at: .info, file: file, function: function, line: line, column: column)
        case .warning(let warning):
            self.log(warning, at: .warning, file: file, function: function, line: line, column: column)
        }
    }
}
