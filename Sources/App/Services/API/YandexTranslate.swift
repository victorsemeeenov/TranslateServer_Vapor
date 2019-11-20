//
//  YandexTranslate.swift
//  
//
//  Created by Victor on 19.11.2019.
//

import Moya
import Foundation
import Vapor

enum YandexTranslate: TargetType {
    case translateWord(word: String, language: String)
    case translateText(text: String, language: String)
    
    var baseURL: URL {
        switch self {
        case .translateWord:
            return URL(string: "https://dictionary.yandex.net/api/v1/dicservice.json")!
        case .translateText:
            return URL(string: "https://translate.yandex.net/api/v1.5/tr.json")!
        }
    }
    
    var path: String {
        switch self {
        case .translateWord:
            return "lookup"
        case .translateText:
            return "translate"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .translateWord, .translateText:
            return .post
        }
    }
    
    var sampleData: Data {
        Data()
    }
    
    var task: Task {
        let string = try! String.dataFromFile("database_config.json")!
        let apiKeys = try! JSONDecoder().decode(APIKeys.self, from: string)
        switch self {
        case .translateText(let text, let lang):
            return .requestParameters(parameters: ["key": apiKeys.yandexTranslateApiKey, "text": text, "lang": lang], encoding: URLEncoding.queryString)
        case .translateWord(let word, let lang):
            return .requestParameters(parameters: ["key": apiKeys.yandexDictApiKey, "lang": lang, "text": word, "ui": "ru", "flags": 2], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
