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
    func select(id: UUID, eventLoop: EventLoop) -> EventLoopFuture<T?>
    func save(data: Data, eventLoop: EventLoop) -> EventLoopFuture<T>
    func delete(id: UUID, eventLoop: EventLoop) -> EventLoopFuture<Bool>
}
