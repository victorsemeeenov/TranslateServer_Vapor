//
//  File.swift
//  
//
//  Created by Victor on 23.11.2019.
//

import Vapor

class BookStorageService: BookStorage {
    func sentence(for bookId: Int, chapterIndex: Int, sentenceIndex: Int) -> EventLoopFuture<Sentence> {
        
    }
    
    func uploadBook(from data: Data) -> EventLoopFuture<Book> {
        
    }
    
    func getBook(for bookId: Int) -> EventLoopFuture<Book> {
        
    }
}


