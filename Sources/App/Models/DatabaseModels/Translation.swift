//
//  Translation.swift
//  
//
//  Created by Victor on 19.11.2019.
//

import FluentPostgreSQL

struct Translation: PostgreSQLModel {
    var id: Int?
    var value: String
    
    var wordTranslation: Children<Translation, WordTranslation> {
        return children(\.word_id)
    }
}

extension Translation: Migration {}
