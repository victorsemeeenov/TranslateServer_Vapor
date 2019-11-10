//
//  WordSentences.swift
//  
//
//  Created by Victor on 11.11.2019.
//

import FluentPostgreSQL

struct  WordSentence: PostgreSQLModel {
    var id: Int?
    var word_id: Int
    var sentence_id: Int
    var index: Int
}
