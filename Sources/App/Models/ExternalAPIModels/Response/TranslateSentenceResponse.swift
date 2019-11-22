//
//  File.swift
//  
//
//  Created by Victor on 22.11.2019.
//

import Foundation
import SwiftyJSON

struct TranslateSentenceResponse: JSONDecodable {
    var code: UInt?
    var lang: String?
    var translations: [String]
    
    var language: Language.LanguageType? {
        guard let lang = lang else {return nil}
        return Language.LanguageType(rawValue: lang)
    }
    
    init(from json: JSON) throws {
        self.code = json["code"].uInt
        self.lang = json["lang"].string
        self.translations = json["text"].array?.filter({ (json) -> Bool in
            return json.string != nil
        })
            .map({ (json) -> String in
                return json.string!
            }) ?? []
    }
}
