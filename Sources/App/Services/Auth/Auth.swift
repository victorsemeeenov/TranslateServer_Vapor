//
//  Auth.swift
//  
//
//  Created by Victor on 16.11.2019.
//

import Vapor

protocol Auth: ServiceType {
    func registerUser(conn: DatabaseConnectable, user: RegisterUserRequest) -> EventLoopFuture<(RefreshToken, AccessToken)>
    func loginUser(conn: DatabaseConnectable, user: LoginUserRequest) -> EventLoopFuture<(RefreshToken, AccessToken)>
    func authorizeUser(conn: DatabaseConnectable, accessToken: String) -> EventLoopFuture<User>
    func checkToken(conn: DatabaseConnectable, accessToken: String) -> EventLoopFuture<AccessToken>
    func refreshToken(userId: Int, conn: DatabaseConnectable, refreshToken: String) -> EventLoopFuture<(RefreshToken, AccessToken)>
}
