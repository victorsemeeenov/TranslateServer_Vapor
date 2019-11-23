//
//  BookStorage.swift
//  
//
//  Created by Victor on 22.11.2019.
//

import Vapor

protocol BookStorage {
    func sentence(for bookId: Int, chapterIndex: Int, sentenceIndex: Int) -> Future<Sentence>
    func uploadBook(from data: Data) -> Future<Book>
    func getBook(for bookId: Int) -> Future<Book>
}
