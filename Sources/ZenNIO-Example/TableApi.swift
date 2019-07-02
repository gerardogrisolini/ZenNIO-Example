//
//  File.swift
//  ZenNIO
//
//  Created by Gerardo Grisolini on 09/01/2019.
//

import Foundation
import NIO

protocol TableApi {
    associatedtype T: Codable
    func select(eventLoop: EventLoop) -> EventLoopFuture<[T]>
    func select(id: Int, eventLoop: EventLoop) -> EventLoopFuture<T?>
    func insert(data: Data, eventLoop: EventLoop) -> EventLoopFuture<T>
    func update(data: Data, eventLoop: EventLoop) -> EventLoopFuture<T>
    func delete(id: Int, eventLoop: EventLoop) -> EventLoopFuture<Bool>
}
