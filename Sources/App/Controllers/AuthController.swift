//
//  AurhController.swift
//  
//
//  Created by Victor on 12.11.2019.
//

import Vapor

final class AuthController: RouteCollection {
    func boot(router: Router) throws {
        router.post("api/register", use: register)
        router.post("api/login", use: login)
    }
    
    func register(_ req: Request) throws -> Future<AuthResponse> {
        let auth = try req.make(Auth.self)
        return req.decode(RegisterUserRequest.self, conn: req)
            .then { (request) -> EventLoopFuture<(RefreshToken, AccessToken)> in
                return auth.registerUser(conn: req, user: request)
        }
        .map { (refreshToken, accessToken) -> AuthResponse in
            return AuthResponse(accessToken: accessToken.value,
                                refreshToken: refreshToken.value,
                                expiredDate: accessToken.expired_in)
        }
    }
    
    func login(_ req: Request) throws -> Future<AuthResponse> {
        let auth = try req.make(Auth.self)
        return req.decode(LoginUserRequest.self, conn: req)
            .then { (request) -> EventLoopFuture<(RefreshToken, AccessToken)> in
                return auth.loginUser(conn: req, user: request)
        }
        .map { (refreshToken, accessToken) -> (AuthResponse) in
            return AuthResponse(accessToken: accessToken.value,
                                refreshToken: refreshToken.value,
                                expiredDate: accessToken.expired_in)
        }
    }
}
