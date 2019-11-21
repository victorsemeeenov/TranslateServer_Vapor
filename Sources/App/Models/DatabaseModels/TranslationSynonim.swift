//
//  File.swift
//  
//
//  Created by Victor on 21.11.2019.
//

import FluentPostgreSQL

struct TranslationSynonim: Pivot {
    typealias Left = Translation
    typealias Right = Synonim
    typealias Database = PostgreSQLDatabase
    typealias ID = Int
    
    var id: Int?
    var translation_id: Int
    var synonim_id: Int
    
    static var leftIDKey: WritableKeyPath<TranslationSynonim, Int> {
        return \.translation_id
    }
    static var rightIDKey: WritableKeyPath<TranslationSynonim, Int> {
        return \.synonim_id
    }
    static var idKey: WritableKeyPath<TranslationSynonim, Int?> {
        return \.id
    }
}
