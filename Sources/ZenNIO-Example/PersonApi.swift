//
//  PersonApi.swift
//  ZenNIO-Example
//
//  Created by Gerardo Grisolini on 10/01/2019.
//

import NIO

class PersonApi : ApiProtocol {
    
    func select() -> EventLoopFuture<[Person]> {
        return Person().query(orderby: ["lastName", "firstName"])
    }
    
    func select(id: Int) -> EventLoopFuture<Person> {
        let item = Person()
        return item.get(id).map { () -> Person in
            item
        }
    }
    
    func save(item: Person) -> EventLoopFuture<Person> {
        return item.save().map { id -> Person in
            item.id = id as! Int
            return item
        }
    }
    
    func delete(id: Int) -> EventLoopFuture<Bool> {
        return Person().delete(id)
    }
}
