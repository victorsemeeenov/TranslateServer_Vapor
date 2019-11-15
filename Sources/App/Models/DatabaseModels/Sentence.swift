//
//  Sentence.swift
//  
//
//  Created by Victor on 11.11.2019.
//

import Foundation
import FluentPostgreSQL

struct Sentence: PostgreSQLModel {
    var id: Int?
    var value: String
    var index: Int
    var chapter_id: Int
    
    var chapter: Parent<Sentence, Chapter> {
        return parent(\.chapter_id)
    }
}
