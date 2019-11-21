//
//  TranslationService.swift
//  
//
//  Created by Victor on 19.11.2019.
//

import Vapor
import Moya
import SwiftyJSON

class TranslationService: TranslationProtocol {
    let provider: MoyaProvider<YandexTranslate> = .init()
}

//MARK: -TranslateWord
extension TranslationService {
    func translate(word: String,
                   language: Language.LanguageType?,
                   conn: DatabaseConnectable) -> Future<((Word, Translation), [Synonim])> {
        return findWordTranslationInDB(word: word,
                                       language: language ?? .en_ru,
                                       conn: conn)
        .catchFlatMap({ (error) -> (EventLoopFuture<((Word, Translation), [Synonim])>) in
            if let err = error as? TranslationError {
                PrintLogger().log(.warning(err), file: #file, function: #function, line: #line, column: #column)
            }
            return self.getWordTranslationRequest(word: word, language: language ?? .en_ru, conn: conn)
        })
    }
    
    private func findWordTranslationInDB(word: String,
                                         language: Language.LanguageType,
                                         conn: DatabaseConnectable) -> Future<((Word, Translation), [Synonim])> {
        let wordQuery = Word.query(on: conn)
            .filter(\.value, .equal, word)
            .first()
            .map { (dbWord) -> (Word) in
                if let validWord = dbWord {
                    return validWord
                } else {
                    throw TranslationError.cantFindWordInDB
                }
            }
        let wordTranslation = wordQuery
            .flatMap { (word) -> EventLoopFuture<(Word, Translation?)> in
                let translation = try word.translation
                    .query(on: conn)
                    .first()
                return wordQuery.and(translation)
            }
        .map { (word, translation) -> (Word, Translation) in
            if let validTranslation = translation {
                return (word, validTranslation)
            } else {
                throw TranslationError.cantFindWordTranslationInDB
            }
        }
        return wordTranslation.flatMap { (word, translation) -> EventLoopFuture<((Word, Translation), [Synonim])> in
            return try wordTranslation.and(translation.synonyms.query(on: conn).all())
        }
    }
    
    private func getWordTranslationRequest(word: String,
                                           language: Language.LanguageType,
                                           conn: DatabaseConnectable) -> Future<((Word, Translation), [Synonim])> {
        return provider.request(.translateWord(word: word, language: language.rawValue), eventLoop: conn.eventLoop)
            .flatMap({ (response) -> EventLoopFuture<((Word, Translation), [Synonim])> in
                return try self.getWordTranslations(responseData: response.data,
                                                    word: word,
                                                    conn: conn,
                                                    language: language)
                                           
            })
    }
    
    private func getWordTranslations(responseData: Data,
                                     word: String,
                                     conn: DatabaseConnectable,
                                     language: Language.LanguageType) throws -> Future<((Word, Translation), [Synonim])> {
        let json = try JSON(data: responseData)
        let translateWordResponse = try TranslateWordResponse.init(from: json)
        if let translationValue = translateWordResponse.translation.text,
            let transcription = translateWordResponse.transcription,
            let partOfSpeech = translateWordResponse.partOfSpeech {
            let translationCreate = Translation(value: translationValue).create(on: conn)
            let wordCreate = Word(value: word,
                                  transcription: transcription,
                                  partOfSpeech: partOfSpeech,
                                  languageId: language.id)
            .create(on: conn)
            let synonimsCreate = wordCreate
                .flatMap({ (word) -> (Future<[Synonim]>) in
                    return self.createSynonims(from: translateWordResponse.synonims,
                                                   wordId: word.id!,
                                                   conn: conn)
                    })
            return wordCreate
            .and(translationCreate)
            .and(synonimsCreate)
        }
        return .fail(eventLoop: conn.eventLoop, error: APIError.modelFieldsEqualNil)
    }
    
    private func createSynonims(from words: [WordMean],
                                wordId: Int,
                                conn: DatabaseConnectable) -> Future<[Synonim]> {
        var futures: [Future<Synonim>] = []
        for word in words {
            if let value = word.text {
                let synonim = Synonim(wordId: wordId,
                               value: value,
                               partOfSpeech: word.partOfSpeech,
                    gender: word.gender).create(on: conn)
                futures.append(synonim)
            }
        }
        return futures.flatten(on: conn)
    }
}

//MARK: -Translate sentence
extension TranslationService {
    func translate(text: String,
                   language: Language.LanguageType?,
                   conn: DatabaseConnectable) -> Future<(Sentence, SentenceTranslation)> {
        return findSentenceTranslationInDB(sentence: text,
                                           language: language ?? .en_ru,
                                           conn: conn)
    }
    
    private func findSentenceTranslationInDB(sentence: String,
                                            language: Language.LanguageType,
                                            conn: DatabaseConnectable) -> Future<(Sentence, SentenceTranslation)> {
        let sentence = Sentence.query(on: conn)
            .filter(\.value, .equal, sentence)
            .first()
            .map { (sentence) -> (Sentence) in
                if let validSentence = sentence {
                    return validSentence
                } else {
                    throw TranslationError.cantFindSentenceInDb
                }
            }
        let translation = sentence.flatMap { (sentence) -> Future<SentenceTranslation?> in
            return SentenceTranslation.query(on: conn)
                .filter(\.sentence_id, .equal, sentence.id!)
                .first()
        }
        .map { (translation) -> (SentenceTranslation) in
            if let validTranslation = translation {
                return validTranslation
            } else {
                throw TranslationError.cantFindSentenceTranlsationinDB
            }
        }
        return sentence.and(translation)
    }
}
