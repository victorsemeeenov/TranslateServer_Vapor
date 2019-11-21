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
    
    var word: Siblings<Translation, Word, WordTranslation> {
        return siblings()
    }
    
    var synonyms: Siblings<Translation, Synonim, TranslationSynonim> {
        return siblings()
    }
    
    init(value: String) {
        self.value = value
    }
}

extension Translation: Migration {}
