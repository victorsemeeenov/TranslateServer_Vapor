//
//  TranslationService.swift
//  
//
//  Created by Victor on 19.11.2019.
//

import Vapor
import Moya
import LanguageDetector

class TranslationService: TranslationProtocol {
    let provider: MoyaProvider<YandexTranslate> = .init()
    
    func translate(word: String, language: Language.LanguageType?, conn: DatabaseConnectable) -> EventLoopFuture<Translation> {
        return Word.query(on: conn)
            .filter(\.value, .equal, word)
            .first()
            .flatMap { (dbWord) -> EventLoopFuture<Translation> in
                if let validWord = dbWord {
                    return self.findTranslation(conn: conn, word: validWord)
                } else {
                    throw TranslationError.cantFindWordInDB
                }
            }
        .catchFlatMap({ (error) -> (EventLoopFuture<Translation>) in
            if let err = error as? TranslationError {
                PrintLogger().log(.warning(err), file: #file, function: #function, line: #line, column: #column)
            }
            return self.getWordTranslationRequest(word: word, language: language ?? .en_ru, conn: conn)
        })
    }
    
    private func getWordTranslationRequest(word: String, language: Language.LanguageType, conn: DatabaseConnectable) -> Future<Translation> {
        return provider.request(.translateWord(word: word, language: language.rawValue), eventLoop: conn.eventLoop)
            .map { (response) -> (Translation) in
                return try JSONDecoder().decode(Translation.self, from: response.data)
        }
    }
    
    private func validateTextLanguage(conn: DatabaseConnectable, text: String) -> EventLoopFuture<Bool> {
        let promise = conn.eventLoop.newPromise(of: EventLoopFuture<Bool>)
        
    }
    
    
    
    private func findTranslation(conn: DatabaseConnectable, word: Word) -> Future<Translation> {
        return WordTranslation.query(on: conn)
            .filter(\.word_id, .equal, word.id!)
            .first()
            .map { (translation) -> (WordTranslation) in
                if let validTranslation = translation {
                    return validTranslation
                } else {
                    throw TranslationError.cantFindWordTranslationInDB
                }
        }
        .flatMap { (wordTranslation) -> EventLoopFuture<Translation> in
            return wordTranslation.translation.get(on: conn)
        }
    }
    
    func translate(text: String, language: Language.LanguageType?, conn: DatabaseConnectable) -> EventLoopFuture<SentenceTranslation> {
//        ret
    }
}
