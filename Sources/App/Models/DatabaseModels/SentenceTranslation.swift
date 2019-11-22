//
//  SentenceTranslation.swift
//  
//
//  Created by Victor on 19.11.2019.
//

import FluentPostgreSQL

struct SentenceTranslation: PostgreSQLModel {
    var id: Int?
    var sentence_id: Int
    var language_id: Int
    var value: String
    
    init(sentenceId: Int,
         languageId: Int,
         value: String) {
        self.sentence_id = sentenceId
        self.language_id = languageId
        self.value = value
    }
}

extension SentenceTranslation: Migration {}
