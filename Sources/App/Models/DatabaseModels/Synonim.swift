//
//  Synonim.swift
//  
//
//  Created by Victor on 21.11.2019.
//

import FluentPostgreSQL

struct Synonim: PostgreSQLModel {
    var id: Int?
    var word_id: Int
    var value: String
    var part_of_speech: String?
    var gender: String?
    
    var translations: Siblings<Synonim, Translation, TranslationSynonim> {
        return siblings()
    }
    
    init(wordId: Int,
         value: String,
         partOfSpeech: String?,
         gender: String?) {
        self.word_id = wordId
        self.value = value
        self.part_of_speech = partOfSpeech
        self.gender = gender
    }
}
