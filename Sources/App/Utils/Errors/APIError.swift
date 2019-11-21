//
//  APIError.swift
//  
//
//  Created by Victor on 21.11.2019.
//

import Vapor

enum APIError: AbortError {
    enum API: String {
        case yandexTranslate = "Yandex Translate"
        case yandexDictionary = "Yandex Dictionary"
    }
    
    case error(code: UInt, message: String)
    case modelFieldsEqualNil
    
    var status: HTTPResponseStatus {
        switch self {
        case .error(let code, let message):
            return .custom(code: code, reasonPhrase: "Reason: \(message)")
        case .modelFieldsEqualNil:
            return .noContent
        }
    }
    
    var identifier: String {
        return "Error"
    }
    
    var reason: String {
        switch self {
        case .error(let code, let message):
            return "Code: \(code), Reason: \(message))"
        case .modelFieldsEqualNil:
            return "Не удалось получить перевод"
        }
    }
}
