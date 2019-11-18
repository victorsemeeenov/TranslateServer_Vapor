//
//  File.swift
//  
//
//  Created by Victor on 12.11.2019.
//

import Vapor
import Crypto
import FluentPostgreSQL

final class AuthService: Auth {
    //MARK: -Auth
    func registerUser(conn: DatabaseConnectable,
                      user: RegisterUserRequest) -> EventLoopFuture<(RefreshToken, AccessToken)> {
        do {
            let password = try SHA1.hash(user.password)
            let newUser = User(name: user.username, email: user.email, passwordHash: password.hexEncodedString())
            return User.query(on: conn)
                .filter(\.name == newUser.name)
                .first()
                .map({ (user) -> (Void) in
                    if let _ = user {
                        throw AuthError.userExistWithName(name: newUser.name)
                    } else {
                        return
                    }
                })
                .flatMap({ (_) -> EventLoopFuture<User?> in
                    return User.query(on: conn)
                        .filter(\.email == newUser.email)
                    .first()
                })
                .map({ (user) -> (Void) in
                    if let _ = user {
                        throw AuthError.userExistWithEmail(email: newUser.email)
                    } else {
                        return
                    }
                })
                .flatMap({ (_) -> EventLoopFuture<(RefreshToken, AccessToken)> in
                    return conn.transact { (conn) -> EventLoopFuture<(RefreshToken, AccessToken)> in
                        newUser.create(on: conn)
                            .then { (user) -> EventLoopFuture<(RefreshToken, AccessToken)> in
                                return self.createNewTokens(on: conn,
                                                            user: user)

                        }
                    }
                })
                .flatMap { (refreshToken, accessToken) -> EventLoopFuture<(RefreshToken, AccessToken)> in
                    return refreshToken.create(on: conn)
                        .and(accessToken.create(on: conn))
            }
        } catch {
            return .fail(eventLoop: conn.eventLoop, error: error)
        }
    }
    
    func loginUser(conn: DatabaseConnectable,
                   user: LoginUserRequest) -> EventLoopFuture<(RefreshToken, AccessToken)> {
        do {
            let password = try SHA1.hash(user.password)
            let user = User.query(on: conn).filter(\.name == user.username)
                .filter(\.passwordHash == password.hexEncodedString())
                .first()
                .map({(user) -> User in
                    guard let validUser = user else {
                        throw AuthError.userNotFound
                    }
                    return validUser
                })
            let refrehToken = user.flatMap({ (user) -> EventLoopFuture<RefreshToken?> in
                return try user.refreshTokens
                .query(on: conn)
                .first()
            })
                .map({ (refreshToken) -> (RefreshToken) in
                    guard let validToken = refreshToken else {
                        throw AuthError.refreshTokenNotFinded(token: nil)
                    }
                    return validToken
                })
            return user.and(refrehToken)
                .flatMap({ (arg) -> EventLoopFuture<(RefreshToken, AccessToken)> in
                    
                    let (user, refreshToken) = arg
                    return self.refreshToken(userId: user.id!,
                                             conn: conn,
                                             refreshToken: refreshToken.value)
                })
                .flatMap { (refreshToken, accessToken) -> EventLoopFuture<(RefreshToken, AccessToken)> in
                    return refreshToken.create(on: conn)
                        .and(accessToken.create(on: conn))
            }
        } catch {
            return .fail(eventLoop: conn.eventLoop, error: error)
        }
    }
    
    func authorizeUser(conn: DatabaseConnectable,
                       accessToken: String) -> EventLoopFuture<User> {
        return checkToken(conn: conn, accessToken: accessToken)
            .flatMap { (token) -> EventLoopFuture<User?> in
                return User.find(token.user_id, on: conn
                )
            }
            .map { (user) -> (User) in
                if let validUser = user {
                    return validUser
                } else {
                    throw AuthError.userNotFound
                }
            }
    }
    
    //MARK: -Token
    func checkToken(conn: DatabaseConnectable,
                    accessToken: String) -> EventLoopFuture<AccessToken> {
        return AccessToken.query(on: conn)
            .filter(\.value == accessToken)
            .first()
            .map { (token) -> AccessToken in
                guard let validToken = token else {
                    throw AuthError.accessTokenNotFinded(token: accessToken)
                }
                if validToken.expired_in < Date() {
                    return validToken
                } else {
                    throw AuthError.accessTokenExpiredIn(token: validToken.value,
                                                         expiredDate: validToken.expired_in)
                }
            }
    }
    
    func refreshToken(userId: Int,
                      conn: DatabaseConnectable,
                      refreshToken: String) -> EventLoopFuture<(RefreshToken, AccessToken)> {
        return conn.transact { (conn) -> EventLoopFuture<(RefreshToken, AccessToken)> in
            self.deleteOldTokens(on: conn, userId: userId)
                .flatMap { (_) -> EventLoopFuture<User?> in
                    return User.find(userId, on: conn)
                }
                .flatMap { (user) -> EventLoopFuture<(RefreshToken, AccessToken)> in
                    guard let validUser = user else {
                        throw AuthError.userNotFound
                    }
                    return self.createNewTokens(on: conn, user: validUser)
                }
        }
    }
    
    private func deleteOldTokens(on conn: DatabaseConnectable,
                                 userId: Int) -> Future<Void> {
            RefreshToken.query(on: conn)
                .filter(\.user_id == userId)
                .first()
                .map({ (refreshToken) -> (RefreshToken) in
                    if let token = refreshToken {
                        return token
                    } else {
                        throw AuthError.refreshTokenNotFinded(token: nil)
                    }
                })
                .flatMap({ (refreshToken) -> EventLoopFuture<Void> in
                    return refreshToken.delete(on: conn)
                })
                .flatMap({ (_) -> EventLoopFuture<AccessToken?> in
                    return AccessToken.query(on: conn)
                        .filter(\.user_id == userId)
                        .first()
                })
                .map({ (accessToken) -> (AccessToken) in
                    if let token = accessToken {
                        return token
                    } else {
                        throw AuthError.refreshTokenNotFinded(token: nil)
                    }
                })
                .flatMap({ (accessToken) -> EventLoopFuture<Void> in
                    return accessToken.delete(on: conn)
                })
    }
            
    private func createNewTokens(on conn: DatabaseConnectable,
                                 user: User) -> Future<(RefreshToken, AccessToken)> {
        do {
            let refreshToken: RefreshToken = try createToken(user: user, days: 30)
            let accessToken: AccessToken = try createToken(user: user, days: 15)
            return .success(eventLoop: conn.eventLoop, result: (refreshToken, accessToken))
        } catch {
            return .fail(eventLoop: conn.eventLoop, error: error)
        }
    }
    
    private func createToken<T: Token>(user: User, days: Int) throws -> T {
        do {
            return try T.generate(user: user, days: days)
        } catch {
            throw error
        }
    }
}

extension AuthService {
    static var serviceSupports: [Any.Type] {
        return [Auth.self]
    }
    
    static func makeService(for container: Container) throws -> Self {
        return .init()
    }
}
