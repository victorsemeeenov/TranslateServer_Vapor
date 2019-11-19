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
}

extension SentenceTranslation: Migration {}
