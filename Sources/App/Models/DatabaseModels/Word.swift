//
//  Word.swift
//  
//
//  Created by Victor on 10.11.2019.
//

import Vapor
import FluentPostgreSQL

struct Word: PostgreSQLModel {
    var id: Int?
    var value: String
    
    var sentences: Siblings<Word, Sentence, WordSentence> {
        return siblings()
    }
}
