//
//  PersonApi.swift
//  ZenNIO-Example
//
//  Created by Gerardo Grisolini on 10/01/2019.
//

import Foundation
import NIO
import ZenPostgres


class PersonApi : TableApi {

    private let db: Database
    
    init(db: Database) {
        self.db = db
        do {
            try Person().create()
        } catch {
            print(error)
        }
    }
    
    func select(eventLoop: EventLoop) -> EventLoopFuture<[Person]> {
        let promise = eventLoop.makePromise(of: [Person].self)
        self.db.connectAsync { conn in
            if let db = conn {
                Person(db: db).queryAsync(orderby: ["lastName", "firstName"]) { (result: Result<[Person], Error>) in
                    switch result {
                    case .success(let rows):
                        promise.succeed(rows)
                    case .failure(let error):
                        promise.fail(error)
                    }
                    db.disconnect()
                }
            }
        }
        
        return promise.futureResult
    }
    
    func select(id: Int, eventLoop: EventLoop) -> EventLoopFuture<Person?> {
        let promise = eventLoop.makePromise(of: Person?.self)
        self.db.connectAsync { conn in
            if let db = conn {
                Person(db: db).getAsync(id) { (result: Result<Person?, Error>) in
                    switch result {
                    case .success(let row):
                        promise.succeed(row)
                    case .failure(let error):
                        promise.fail(error)
                    }
                    db.disconnect()
                }
            }
        }
        
        return promise.futureResult
    }
    
    func insert(data: Data, eventLoop: EventLoop) -> EventLoopFuture<Person> {
        let promise = eventLoop.makePromise(of: Person.self)
        do {
            let item = try JSONDecoder().decode(Person.self, from: data)
            self.db.connectAsync { conn in
                if let db = conn {
                    item.db = db
                    item.saveAsync { id in
                        item.id = id as! Int
                        promise.succeed(item)
                        db.disconnect()
                    }
                } else {
                    promise.fail(ZenError.connectionNotFound)
                }
            }
        } catch {
            promise.fail(error)
        }
        
        return promise.futureResult
    }

    func update(data: Data, eventLoop: EventLoop) -> EventLoopFuture<Person> {
        let promise = eventLoop.makePromise(of: Person.self)

        do {
            let item = try JSONDecoder().decode(Person.self, from: data)

            self.db.connectAsync { conn in
                if let db = conn {
                    item.db = db
                    item.saveAsync { _ in
                        promise.succeed(item)
                        db.disconnect()
                    }
                } else {
                    promise.fail(ZenError.connectionNotFound)
                }
            }
            
        } catch {
            promise.fail(error)
        }
        
        return promise.futureResult
    }
    
    func delete(id: Int, eventLoop: EventLoop) -> EventLoopFuture<Bool> {
        let promise = eventLoop.makePromise(of: Bool.self)

        self.db.connectAsync { conn in
            if let db = conn {
                Person(db: db).deleteAsync(id) {  (result: Result<Int, Error>) in
                    switch result {
                    case .success(let count):
                        promise.succeed(count > 0)
                    case .failure(let error):
                        promise.fail(error)
                    }
                    db.disconnect()
                }
            }
        }

        return promise.futureResult
    }
}
