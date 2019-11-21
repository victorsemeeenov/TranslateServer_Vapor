//
//  TranslationError.swift
//  App
//
//  Created by Victor on 20.11.2019.
//

import Vapor

enum TranslationError: Debuggable {
    case cantFindWordTranslationInDB
    case cantFindWordInDB
    case nilValueForSynonim
    case cantFindSentenceInDb
    case cantFindSentenceTranlsationinDB
    
    var identifier: String {
        return "Error"
    }
    
    var reason: String {
        switch self {
        case .cantFindWordTranslationInDB:
            return "Невозможно найти перевод слова в БД"
        case .cantFindWordInDB:
            return "Невозможно найти слово в БД"
        case .nilValueForSynonim:
            return "Синоним не имеет значения"
        case .cantFindSentenceInDb:
            return "Невозможно найти предложение в БД"
        case .cantFindSentenceTranlsationinDB:
            return "Невозможно найти перевод предложения в БД"
        }
    }
}
