//
//  Future+Flatten.swift
//  
//
//  Created by Victor on 21.11.2019.
//

import Vapor

public typealias LazyFuture<T> = () throws -> Future<T>

extension Collection {
    public func syncFlatten<T>(on worker: Worker) -> Future<[T]> where Element == LazyFuture<T> {
        let promise = worker.eventLoop.newPromise([T].self)
        
        var elements: [T] = []
        elements.reserveCapacity(self.count)
        
        var iterator = makeIterator()
        func handle(_ future: LazyFuture<T>) {
            do {
                try future().do { res in
                    elements.append(res)
                    if let next = iterator.next() {
                        handle(next)
                    } else {
                        promise.succeed(result: elements)
                    }
                }.catch { error in
                    promise.fail(error: error)
                }
            } catch {
                promise.fail(error: error)
            }
        }

        if let first = iterator.next() {
            handle(first)
        } else {
            promise.succeed(result: elements)
        }

        return promise.futureResult
    }
}

extension Collection where Element == LazyFuture<Void> {
    public func syncFlatten(on worker: Worker) -> Future<Void> {
        let flatten: Future<[Void]> = self.syncFlatten(on: worker)
        return flatten.transform(to: ())
    }
}

extension Collection {
    public func flatten<T>(on worker: Worker) -> Future<[T]> where Element == Future<T> {
        return Future.whenAll(Array(self), eventLoop: worker.eventLoop)
    }
}

extension Collection where Element == Future<Void> {
    /// Flattens an array of void futures into a single one.
    public func flatten(on worker: Worker) -> Future<Void> {
        return Future.andAll(Array(self), eventLoop: worker.eventLoop)
    }
}
