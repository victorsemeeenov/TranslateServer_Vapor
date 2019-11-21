//
//  Translation.swift
//  
//
//  Created by Victor on 10.11.2019.
//

import FluentPostgreSQL
import Vapor

struct WordTranslation: Pivot {
    typealias Database = PostgreSQLDatabase
    typealias ID = Int
    typealias Left = Word
    typealias Right = Translation
    
    var id: Int?
    var word_id: Int
    var translation_id: Int
    
    init(wordId: Int,
         translationId: Int) {
        self.word_id = wordId
        self.translation_id = translationId
    }
    
    static var leftIDKey: WritableKeyPath<WordTranslation, Int> {
        return \.word_id
    }
    
    static var rightIDKey: WritableKeyPath<WordTranslation, Int> {
        return \.translation_id
    }
    
    static var idKey: WritableKeyPath<WordTranslation, Int?> {
        return \.id
    }
}

extension WordTranslation: Migration {}

