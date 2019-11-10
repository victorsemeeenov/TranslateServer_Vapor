//
//  File.swift
//  
//
//  Created by Victor on 10.11.2019.
//

import Foundation
import SwiftyJSON

protocol JSONDecodable {
    init(from json: JSON)
}

extension Array: JSONDecodable where Element: JSONDecodable {
    init(from json: JSON) {
        self = []
        guard let array = json.array else {return}
        for json in array {
            self.append(Element.init(from: json))
        }
    }
}
