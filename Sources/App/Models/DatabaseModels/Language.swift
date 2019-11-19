//
//  Language.swift
//  
//
//  Created by Victor on 19.11.2019.
//

import FluentPostgreSQL

struct Language: PostgreSQLModel {
    var id: Int?
    var value: String
    
    var wordTranslation: Children<Language, WordTranslation> {
        return children(\.language_id)
    }
}

extension Language: Migration {}
