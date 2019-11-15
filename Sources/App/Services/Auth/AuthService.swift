//
//  File.swift
//  
//
//  Created by Victor on 12.11.2019.
//

import Vapor
import Crypto
import FluentPostgreSQL
import JWT

class AuthService: Service {
    //MARK: -Auth
    func registerUser(conn: DatabaseConnectable,
                      user: RegisterUserRequest) -> EventLoopFuture<(RefreshToken, AccessToken)> {
        do {
            let password = try SHA1.hash(user.password)
            let newUser = User(name: user.username, email: user.email, passwordHash: password.hexEncodedString())
            if let _ = try User.query(on: conn).filter(\.name == newUser.name).first().wait() {
                throw AuthError.userExistWithName(name: newUser.name)
            }
            if let _ = try User.query(on: conn).filter(\.email == newUser.email).first().wait() {
                throw AuthError.userExistWithEmail(email: newUser.email)
            }
            return conn.transact { (conn) -> EventLoopFuture<(RefreshToken, AccessToken)> in
                newUser.create(on: conn)
                    .then { (user) -> EventLoopFuture<(RefreshToken, AccessToken)> in
                        return self.createNewTokens(on: conn,
                                                    user: user)
                }
            }
        } catch {
            return .fail(eventLoop: conn.eventLoop, error: error)
        }
    }
    
    func loginUser(conn: DatabaseConnectable,
                   user: LoginUserRequest) -> EventLoopFuture<(RefreshToken, AccessToken)> {
        do {
            let password = try SHA1.hash(user.password)
            let user = try User.query(on: conn).filter(\.name == user.username)
                .filter(\.passwordHash == password.hexEncodedString())
                .first()
                .map({(user) -> User in
                    guard let validUser = user else {
                        throw AuthError.userNotFound
                    }
                    return validUser
                })
                .wait()
            
            return try user.refreshTokens
            .query(on: conn)
            .first()
            .flatMap({ (refreshToken) -> EventLoopFuture<(RefreshToken, AccessToken)> in
                guard let validToken = refreshToken else {
                    throw AuthError.refreshTokenNotFinded(token: nil)
                }
                return try self.refreshToken(userId: user.id!,
                                         conn: conn,
                                         refreshToken: validToken.value)
            })
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
                      refreshToken: String) throws -> EventLoopFuture<(RefreshToken, AccessToken)> {
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
                .thenThrowing({ (refreshToken) -> Void in
                    do {
                        if let deleting = refreshToken?.delete(on: conn) {
                            return try deleting.wait()
                        } else {
                            
                        }
                    } catch {
                        throw error
                    }
                })
                .flatMap({ (_) -> EventLoopFuture<AccessToken?> in
                    return AccessToken.query(on: conn)
                        .filter(\.user_id == userId)
                        .first()
                })
                .thenThrowing { (accessToken) -> Void in
                    do {
                        if let deleting = accessToken?.delete(on: conn) {
                            return try deleting.wait()
                        } else {
                            throw AuthError.accessTokenNotFinded(token: nil)
                        }
                    } catch {
                        throw error
                    }
                }
    }
            
    private func createNewTokens(on conn: DatabaseConnectable,
                                 user: User) -> Future<(RefreshToken, AccessToken)> {
        guard let userId = user.id else {
            return .fail(eventLoop: conn.eventLoop, error: AuthError.notFoundUserId)
        }
        do {
            let userJWT = UserJWT(id: userId, name: user.name)
            let refreshToken: RefreshToken = try createToken(userJWT: userJWT, days: 30)
            let accessToken: AccessToken = try createToken(userJWT: userJWT, days: 15)
            return .success(eventLoop: conn.eventLoop, result: (refreshToken, accessToken))
        } catch {
            return .fail(eventLoop: conn.eventLoop, error: error)
        }
    }
    
    private func createToken<T: Token>(userJWT: UserJWT, days: Int) throws -> T {
        do {
            let data = try JWT(payload: userJWT).sign(using: .hs256(key: "secret"))
            let value = String(data: data, encoding: .utf8) ?? ""
            return T.init(id: nil, value: value, user_id: userJWT.id, expired_in: Date().addDays(days)!)
        } catch {
            throw error
        }
    }
}
