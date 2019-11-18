//
//  Translation.swift
//  
//
//  Created by Victor on 10.11.2019.
//

import FluentPostgreSQL
import Vapor

struct Translation: PostgreSQLModel {
    var id: Int?
    var word_id: Int
    var translation: String
    
    var word: Parent<Translation, Word> {
        return parent(\.word_id)
    }
}

extension Translation: Migration {}

