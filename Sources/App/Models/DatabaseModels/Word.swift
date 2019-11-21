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
    var transcription: String
    var part_of_speech: String
    var language_id: Int
    
    var language: Parent<Word, Language> {
        return parent(\.language_id)
    }
    
    var translation: Siblings<Word, Translation, WordTranslation> {
        return siblings()
    }
    
    init(value: String,
        transcription: String,
        partOfSpeech: String,
        languageId: Int) {
        self.value = value
        self.transcription = transcription
        self.part_of_speech = partOfSpeech
        self.language_id = languageId
    }
}

extension Word: Migration {}
