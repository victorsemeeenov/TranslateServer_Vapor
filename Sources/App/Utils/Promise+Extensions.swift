//
//  File.swift
//  
//
//  Created by Victor on 15.11.2019.
//

import NIO
import Fluent

extension EventLoopFuture {
    static func fail(eventLoop: EventLoop,
                     error: Error) -> EventLoopFuture<T> {
        let promise = eventLoop.newPromise(of: T.self)
        promise.fail(error: error)
        return promise.futureResult
    }
    
    static func success(eventLoop: EventLoop,
                        result: T) -> EventLoopFuture<T> {
        let promise = eventLoop.newPromise(of: T.self)
        promise.succeed(result: result)
        return promise.futureResult
    }
}

extension Optional {
    func validate<T>(conn: DatabaseConnectable) -> EventLoopFuture<T> where Wrapped == EventLoopFuture<T> {
        if self == nil {
            return .fail(eventLoop: conn.eventLoop, error: UtilError.nilValue)
        } else {
            return self!
        }
    }
}
