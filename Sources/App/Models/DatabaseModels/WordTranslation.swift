//
//  Translation.swift
//  
//
//  Created by Victor on 10.11.2019.
//

import FluentPostgreSQL
import Vapor

struct WordTranslation: PostgreSQLModel {
    var id: Int?
    var word_id: Int
    var language_id: Int
    var translation_id: Int
    
    var word: Parent<WordTranslation, Word> {
        return parent(\.word_id)
    }
    
    var language: Parent<WordTranslation, Language> {
        return parent(\.language_id)
    }
    
    var translation: Parent<WordTranslation, Translation> {
        return parent(\.translation_id)
    }
}

extension WordTranslation: Migration {}

