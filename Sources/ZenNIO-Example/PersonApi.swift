//
//  PersonApi.swift
//  ZenNIO-Example
//
//  Created by Gerardo Grisolini on 10/01/2019.
//

import NIO
import ZenNIO
import ZenPostgres

class PersonApi : ApiProtocol {
    
    init() {
        try? setup().wait()
    }
    
    private func setup() -> EventLoopFuture<Void> {
        return ZenPostgres.pool.connect().flatMap { conn -> EventLoopFuture<Void> in
            defer { conn.disconnect() }
            
            let person = Person(connection: conn)
            return person.create().flatMap { () -> EventLoopFuture<Void> in
                return person.query().flatMap { items -> EventLoopFuture<Void>  in
                    let promise = conn.eventLoop.makePromise(of: Void.self)

                    if items.count == 0 {
                        for i in 1...100 {
                            let p = Person(connection: conn)
                            p.firstName = "FirstName \(i)"
                            p.lastName = "LastName \(i)"
                            p.email = "\(i)@domain.com"
                            self.save(item: p).whenComplete { _ in
                                if i == 100 {
                                    promise.succeed(())
                                }
                            }
                        }
                    } else {
                        promise.succeed(())
                    }

                    return promise.futureResult
                }
            }
        }
    }
    
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
