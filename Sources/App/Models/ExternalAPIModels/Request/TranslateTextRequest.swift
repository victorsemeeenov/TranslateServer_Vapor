//
//  TranslateTextRequest.swift
//  
//
//  Created by Victor on 19.11.2019.
//

import Foundation

struct TranslateTextRequest: Encodable {
    let key: String
    let text: String
    let lang: String
}
