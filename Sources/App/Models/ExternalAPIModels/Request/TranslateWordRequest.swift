//
//  TranslateWordRequest.swift
//  
//
//  Created by Victor on 19.11.2019.
//

import Foundation

struct TranslateWordRequest: Encodable {
    let key: String
    let lang: String
    let text: String
    let ui: String
    let flags: Int
}
