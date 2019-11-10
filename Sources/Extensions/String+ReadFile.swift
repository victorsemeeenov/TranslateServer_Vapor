//
//  File.swift
//  
//
//  Created by Victor on 10.11.2019.
//

import Foundation

extension String {
    static func dataFromFile(_ filename: String, ofType type: String? = nil) throws -> String? {
        guard let path = Bundle.main.path(forResource: filename, ofType: type) else {
            return nil
        }
        do {
            let url = URL(fileURLWithPath: path)
            return try String(contentsOf: url)
        }
        catch {
            throw error
        }
    }
}
