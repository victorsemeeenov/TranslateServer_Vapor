//
//  File.swift
//  
//
//  Created by Victor on 13.11.2019.
//

import Vapor

enum AuthError: Debuggable {
    case userExistWithName(name: String)
    case userExistWithEmail(email: String)
    case refreshTokenNotFinded(token: String?)
    case accessTokenNotFinded(token: String?)
    case userNotFound
    case accessTokenExpiredIn(token: String, expiredDate: Date)
    case refreshTokenExpiredIn(token: String, expiredDate: Date)
    case notFoundUserId
    
    var identifier: String {
        return "Error"
    }
    
    var reason: String {
        switch self {
        case .userExistWithName:
            return "Пользователь с таким именем уже существует"
        case .userExistWithEmail:
            return "Пользователь с такой почтой уже существует"
        case .accessTokenNotFinded:
            return "Access token не найден"
        case .refreshTokenNotFinded:
            return "Refresh token не найден"
        case .userNotFound:
            return "Пользователь не найден"
        case .accessTokenExpiredIn:
            return "Access token устарел. Обновите его"
        case .refreshTokenExpiredIn:
            return "Refresh token устарел. Обновите его"
        case .notFoundUserId:
            return "Отсутствует User id"
        }
    }
}
