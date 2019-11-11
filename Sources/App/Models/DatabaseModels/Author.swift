//
//  File.swift
//  
//
//  Created by Victor on 11.11.2019.
//

import FluentPostgreSQL

struct Author: PostgreSQLModel {
    var id: Int?
    var name: String
}

extension Author {
    var book: Siblings<Author, Book, BookAuthor> {
        return siblings()
    }
}
