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
    func registerUser<TokenTransaction: TransactionOperation>(use userRepository: AbstractRepository<User>,
                      tokenTransaction: TokenTransaction
                      user: RegisterRequest) throws -> EventLoopFuture<(AccessToken, RefreshToken)> {
        do {
            let digest = try SHA1.hash(user.password)
            let newUser = User(name: user.username, email: user.email, passwordHash: digest.hexEncodedString())
            if let _ = try userRepository.first(\.name, newUser.name).wait() {
                throw AuthError.userExistWithName(name: newUser.name)
            }
            if let _ = try userRepository.first(\.email, newUser.email).wait() {
                throw AuthError.userExistWithEmail(email: newUser.email)
            }
            let user = try userRepository.create(newUser).wait()
            
        } catch {
            throw error
        }
    }
    
    func authorizeUser(use userRepository: AbstractRepository<User>,
                       accessTokenRepository: AbstractRepository<AccessToken>,
                       accessToken: String) throws -> EventLoopFuture<User> {
        do {
            return try checkToken(accessToken: accessToken,
                                  accessTokenRepository: accessTokenRepository)
                .flatMap({ (token) -> EventLoopFuture<User?> in
                    return try userRepository.find(token.user_id)
                })
                .map({ (user) -> (User) in
                    if let validUser = user {
                        return validUser
                    } else {
                        throw AuthError.userNotFound
                    }
                })
        } catch {
            throw error
        }
    }
    //MARK: -Token
    func checkToken(accessToken: String,
                    accessTokenRepository: AbstractRepository<AccessToken>) throws -> EventLoopFuture<AccessToken> {
        do {
            return try accessTokenRepository.first(\.value, accessToken)
                .map({ (token) -> AccessToken in
                    guard let validToken = token else {
                        throw AuthError.accessTokenNotFinded(token: accessToken)
                    }
                    if validToken.expired_in < Date() {
                        return validToken
                    } else {
                        throw AuthError.accessTokenExpiredIn(token: validToken.value, expiredDate: validToken.expired_in)
                    }
                })
        } catch {
            throw error
        }
    }
    
    func refreshToken<RefreshTokenTransactionOperation: TransactionOperation, AccessTokenTransactionOperation: TransactionOperation, UserRepository: TransactionOperation> (refreshToken: String,
                               transaction: Transaction,
                               refreshTokenRepository: AbstractRepository<RefreshToken>,
                               accessTokenRepository: AbstractRepository<AccessToken>,
                               userRepository: AbstractRepository<User>) throws -> EventLoopFuture<(RefreshToken, AccessToken)> where RefreshTokenTransactionOperation.T == RefreshToken, AccessTokenTransactionOperation.T == AccessToken, UserRepository.T == User
    {
        do {
            return transaction.transact { (transact) -> EventLoopFuture<(RefreshToken, AccessToken)> in
                if let user = try self.deleteOldTokenTransaction(refreshToken: refreshToken,
                                                   transactionProcess: transact,
                                                   refreshTokenRepository: refreshTokenRepository,
                                                   accessTokenRepository: accessTokenRepository, userRepository: userRepository)
                    .wait() {
                    return try self.createNewTokens(user: user,
                    transactionProcess: transact,
                    refreshTokenRepository:refreshTokenRepository, accessTokenRepository: accessTokenRepository)
                } else {
                    throw AuthError.userNotFound
                }
            }
        } catch {
            throw error
        }
    }
    
    private func deleteOldTokenTransaction<RefreshTokenTransactionOperation: TransactionOperation, AccessTokenTransactionOperation: TransactionOperation, UserRepository: TransactionOperation> (refreshToken: String,
                                                                transactionProcess: TransactionProcess,
                                                                refreshTokenRepository: RefreshTokenTransactionOperation,
                                                                accessTokenRepository: AccessTokenTransactionOperation,
                                                                userRepository: UserRepository) throws -> EventLoopFuture<User?> where RefreshTokenTransactionOperation.T == RefreshToken, AccessTokenTransactionOperation.T == AccessToken, UserRepository.T == User {
        do {
            let token = try transactionProcess.addOperation(to: refreshTokenRepository) { (repo) -> EventLoopFuture<RefreshToken?> in
                return try repo.queryFirstOperation(\.value, refreshToken)
            }
            .thenThrowing{ (token) -> (RefreshToken) in
                guard let validToken = token else {
                    throw AuthError.refreshTokenNotFinded(token: refreshToken)
                }
                return validToken
            }.wait()
            
            let deletedRefreshToken = try transactionProcess.addOperation(to: refreshTokenRepository) { (repo) -> EventLoopFuture<RefreshToken> in
                return try repo.deleteOperation(token).map({ (_) -> (RefreshToken) in
                    return token
                })
            }.wait()
            
            let accessToken = try transactionProcess.addOperation(to: accessTokenRepository, { (repo) -> EventLoopFuture<AccessToken?> in
                return try accessTokenRepository.queryFirstOperation(\.user_id, deletedRefreshToken.user_id)
            })
                .map({ (token) -> (AccessToken) in
                    guard let validToken = token else {
                        throw AuthError.accessTokenNotFinded(token: nil)
                    }
                    return validToken
                }).wait()
            
            try transactionProcess.addOperation(to: accessTokenRepository, { (repo) -> EventLoopFuture<Void> in
                return try repo.deleteOperation(accessToken)
                }).wait()
            
            return try userRepository.findOperation(accessToken.user_id)
        } catch {
            throw error
        }
    }
    
    private func createNewTokens<RefreshTokenTransactionOperation: TransactionOperation, AccessTokenTransactionOperation: TransactionOperation>(user: User,
        transactionProcess: TransactionProcess,
                                 refreshTokenRepository: RefreshTokenTransactionOperation,
                                 accessTokenRepository: AccessTokenTransactionOperation) throws -> EventLoopFuture<(RefreshToken, AccessToken)> where RefreshTokenTransactionOperation.T == RefreshToken, AccessTokenTransactionOperation.T == AccessToken  {
        do {
            let refreshTokenOperation = try transactionProcess.addOperation(to: refreshTokenRepository) { (refreshTokenRepo) -> EventLoopFuture<RefreshToken> in
                guard let userId = user.id else {
                    throw AuthError.notFoundUserId
                }
                let userJWT = UserJWT(id: userId,
                                         name: user.name)
                let data = try JWT(payload: userJWT).sign(using: .hs256(key: "secret"))
                let value = String(data: data, encoding: .utf8) ?? ""
                let refreshToken = RefreshToken(value: value,
                                                user_id: userId,
                                                expired_in: Date().addDays(30)!)
                return try refreshTokenRepo.createOperation(refreshToken)
            }
            let accessTokenOperation = try transactionProcess.addOperation(to: accessTokenRepository) { (accessTokenRepo) -> EventLoopFuture<AccessToken> in
                guard let userId = user.id else {
                    throw AuthError.notFoundUserId
                }
                let userJWT = UserJWT(id: userId,
                                      name: user.name)
                let data = try JWT(payload: userJWT).sign(using: .hs256(key: "secret"))
                let value = String(data: data, encoding: .utf8) ?? ""
                let token = AccessToken(value: value,
                                        user_id: userId,
                                        expired_in: Date().addDays(15)!)
                return try accessTokenRepo.createOperation(token)
            }
            return try refreshTokenOperation.and(accessTokenOperation)
        }
    }
}
