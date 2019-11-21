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
        
        var id: Int {
            switch self {
            case .en_ru:
                return 0
            case .fr_ru:
                return 1
            case .de_ru:
                return 2
            }
        }
    }
    
    var id: Int?
    var value: String
    
    var language: LanguageType? {
        return LanguageType(rawValue: value)
    }
}

extension Language: Migration {}
