//
//  Book.swift
//  
//
//  Created by Victor on 10.11.2019.
//

import FluentPostgreSQL

struct Book: PostgreSQLModel {
    var id: Int?
    var name: String
    var number_of_pages: String
    var year: String
}

extension Book {
    var author: Siblings<Book, Author, BookAuthor> {
        return siblings()
    }
}
