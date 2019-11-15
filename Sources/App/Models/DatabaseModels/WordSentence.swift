//
//  WordSentences.swift
//  
//
//  Created by Victor on 11.11.2019.
//

import FluentPostgreSQL

struct  WordSentence: Pivot {
    typealias Database = PostgreSQLDatabase
    typealias ID = Int
       
    typealias Left = Word
    typealias Right = Sentence
    
    var id: Int?
    var word_id: Int
    var sentence_id: Int
    var index: Int
    
    static var idKey: WritableKeyPath<WordSentence, Int?> {
        return \.id
    }

    static var leftIDKey: WritableKeyPath<WordSentence, Int> {
        return \.word_id
    }
    
    static var rightIDKey: WritableKeyPath<WordSentence, Int> {
        return \.sentence_id
    }
}

