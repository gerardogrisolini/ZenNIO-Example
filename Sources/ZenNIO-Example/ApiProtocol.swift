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
    
    func select() throws -> [T]
    
    func select(id: Int) throws -> T?
    
    func insert(data: Data) throws -> T
    
    func update(data: Data) throws
    
    func delete(id: Int) throws
}
