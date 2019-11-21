//
//  File.swift
//  
//
//  Created by Victor on 10.11.2019.
//

import Foundation
import SwiftyJSON

protocol JSONDecodable {
    init(from json: JSON) throws
}

extension Array: JSONDecodable where Element: JSONDecodable {
    init(from json: JSON) throws {
        self = []
        guard let array = json.array else {return}
        do {
            for json in array {
                self.append(try Element.init(from: json))
            }
        } catch {
            throw error
        }
    }
}
