//
//  Translation.swift
//  
//
//  Created by Victor on 19.11.2019.
//

import Vapor

protocol TranslationProtocol {
    func translate(word: String,
                   language: Language.LanguageType?,
                   conn: DatabaseConnectable) -> Future<((Word, Translation), [Synonim])>
    func translate(sentenceIndex: Int,
                   chapterIndex: Int,
                   bookId: Int,
                   language: Language.LanguageType?,
                   conn: DatabaseConnectable) -> Future<(Sentence, SentenceTranslation)>
}
