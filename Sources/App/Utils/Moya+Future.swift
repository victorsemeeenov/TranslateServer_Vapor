//
//  File.swift
//  
//
//  Created by Victor on 20.11.2019.
//

import Moya
import Vapor
import Alamofire

extension MoyaProvider {
    func request(_ target: Target, eventLoop: EventLoop) -> Future<Moya.Response> {
        let promise = eventLoop.newPromise(of: Moya.Response.self)
        self.request(target) { (result) in
            switch result {
            case .success(let response):
                promise.succeed(result: response)
            case .failure(let error):
                promise.fail(error: error)
            }
        }
        return promise.futureResult
    }
}
