//
//  Translation.swift
//  
//
//  Created by Victor on 19.11.2019.
//

import Vapor

protocol TranslationProtocol {
    func translate(word: String, language: Language.LanguageType?, conn: DatabaseConnectable) -> Future<((Word, Translation), [Synonim])>
    func translate(text: String, language: Language.LanguageType?, conn: DatabaseConnectable) -> Future<(Sentence, SentenceTranslation)>
}
