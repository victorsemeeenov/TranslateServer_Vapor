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
    let partOfSpeech: String?
    let gender: String?
    
    init(from json: JSON) {
        self.text = json["text"].string
        self.partOfSpeech = json["pos"].string
        self.gender = json["gen"].string
    }
}

struct TranslateWordResponse: JSONDecodable {
    let text: String?
    let partOfSpeech: String?
    let transcription: String?
    let translation: WordMean
    let synonims: [WordMean]
    let means: [String]
    var examplesAndTranslations: [String: String]
    let code: UInt?
    let message: String?
    
    init(from json: JSON) throws {
        let def = json["def"]
        let tr = def["tr"]
        self.text = def["text"].string
        self.translation = WordMean(from: tr)
        self.partOfSpeech = def["pos"].string
        self.transcription = def["ts"].string
        self.synonims = try .init(from: tr["syn"])
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
        self.code = json["code"].uInt
        self.message = json["message"].string
        if self.message != nil, code != nil {
            throw APIError.error(code: self.code!, message: self.message!)
        }
    }
}
