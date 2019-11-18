//
//  Chapter.swift
//  
//
//  Created by Victor on 10.11.2019.
//

import FluentPostgreSQL


struct Chapter: PostgreSQLModel {
    var id: Int?
    var title: String
    var index: Int
    var index_value: String
    var book_id: Int
    
    var book: Parent<Chapter, Book> {
        return parent(\.book_id)
    }
}

extension Chapter: Migration {}
