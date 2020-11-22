//
//  ApiProtocol.swift
//  ZenNIO
//
//  Created by Gerardo Grisolini on 09/01/2019.
//

import Foundation
import NIO

protocol ApiProtocol {
    
    associatedtype T: Codable
    
    func select() -> EventLoopFuture<[T]>
    
    func select(id: Int) -> EventLoopFuture<T>
    
    func save(item: T) -> EventLoopFuture<T>
    
    func delete(id: Int) -> EventLoopFuture<Bool>
}
