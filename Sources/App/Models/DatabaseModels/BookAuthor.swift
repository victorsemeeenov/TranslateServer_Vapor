//
//  File.swift
//  
//
//  Created by Victor on 11.11.2019.
//

import FluentPostgreSQL

struct BookAuthor: Pivot {
    typealias Left = Book
    typealias Right = Author
    typealias Database = PostgreSQLDatabase
    typealias ID = Int
    
    var id: Int?
    var book_id: Int
    var author_id: Int
    
    static var leftIDKey: WritableKeyPath<BookAuthor, Int> {
        return \.book_id
    }
    
    static var rightIDKey: WritableKeyPath<BookAuthor, Int> {
        return \.author_id
    }
    
    static var idKey: WritableKeyPath<BookAuthor, Int?> {
        return \.id
    }
}
