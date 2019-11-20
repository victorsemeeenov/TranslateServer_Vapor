//
//  Language.swift
//  
//
//  Created by Victor on 19.11.2019.
//

import FluentPostgreSQL

struct Language: PostgreSQLModel {
    enum LanguageType: String {
        case en_ru
        case fr_ru
        case de_ru
    }
    
    var id: Int?
    var value: String
    
    var wordTranslation: Children<Language, WordTranslation> {
        return children(\.language_id)
    }
    
    var language: LanguageType? {
        return LanguageType(rawValue: value)
    }
}

extension Language: Migration {}
