//
//  File.swift
//  ZenNIO
//
//  Created by Gerardo Grisolini on 09/01/2019.
//

import Foundation
import NIO

protocol ApiProtocol {
    
    associatedtype T: Codable
    
    func select(promise: EventLoopPromise<[T]>) -> EventLoopFuture<[T]>
    
    func select(id: Int, promise: EventLoopPromise<T?>) -> EventLoopFuture<T?>
    
    func insert(data: Data, promise: EventLoopPromise<T>) -> EventLoopFuture<T>
    
    func update(data: Data, promise: EventLoopPromise<T>) -> EventLoopFuture<T>
    
    func delete(id: Int, promise: EventLoopPromise<Bool>) -> EventLoopFuture<Bool>
}
