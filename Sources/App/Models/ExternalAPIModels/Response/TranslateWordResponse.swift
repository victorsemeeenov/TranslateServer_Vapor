//
//  File.swift
//  
//
//  Created by Victor on 19.11.2019.
//

import Foundation
import SwiftyJSON

struct WordMean: JSONDecodable {
    let text: String?
    let pos: String?
    let gen: String?
    
    init(from json: JSON) {
        self.text = json["text"].string
        self.pos = json["pos"].string
        self.gen = json["gen"].string
    }
}

struct TranslateWordResponse: JSONDecodable {
    let text: String?
    let pos: String?
    let ts: String?
    let translation: WordMean
    let synonims: [WordMean]
    let means: [String]
    var examplesAndTranslations: [String: String]
    
    init(from json: JSON) {
        let def = json["def"]
        let tr = def["tr"]
        self.text = def["text"].string
        self.translation = WordMean(from: tr)
        self.pos = def["pos"].string
        self.ts = def["ts"].string
        self.synonims = .init(from: tr["syn"])
        self.means = tr["mean"].array?.filter({ (json) -> Bool in
            return json.string != nil
        })
            .map({ (json) -> String in
                return json.string!
            }) ?? []
        let translations = tr["ex"].array?.filter({ (json) -> Bool in
                return json["text"].string != nil && json["tr"]["text"].string != nil
            }) ?? []
        self.examplesAndTranslations = [:]
        for translation in translations {
            self.examplesAndTranslations[translation["text"].string!] = translation["tr"]["text"].string!
        }
    }
}
