//
//  PersonApi.swift
//  ZenNIO-Example
//
//  Created by Gerardo Grisolini on 10/01/2019.
//

import Foundation
import NIO
import ZenPostgres


class PersonApi : ApiProtocol {

    private let db: Database
    
    init(db: Database) {
        self.db = db
        do {
            try Person().create()
        } catch {
            print(error)
        }
    }
    
    func select(promise: EventLoopPromise<[Person]>) -> EventLoopFuture<[Person]> {
        DispatchQueue.global().async {
            do {
                let db = try self.db.connect()
                defer { db.disconnect() }
                let rows: [Person] = try Person(db: db).query(orderby: ["lastName", "firstName"])
                promise.succeed(rows)
            } catch {
                promise.fail(error)
            }
        }
        return promise.futureResult
    }
    
    func select(id: Int, promise: EventLoopPromise<Person?>) -> EventLoopFuture<Person?> {
        DispatchQueue.global().async {
            do {
                let db = try self.db.connect()
                defer { db.disconnect() }
                let row = Person(db: db)
                try row.get(id)
                promise.succeed(row)
            } catch {
                promise.fail(error)
            }
        }
        return promise.futureResult
    }
    
    func insert(data: Data, promise: EventLoopPromise<Person>) -> EventLoopFuture<Person> {
        DispatchQueue.global().async {
            do {
                let item = try JSONDecoder().decode(Person.self, from: data)
                try item.save { id in
                    item.id = id as! Int
                    promise.succeed(item)
                }
            } catch {
                promise.fail(error)
            }
        }

        return promise.futureResult
    }

    func update(data: Data, promise: EventLoopPromise<Person>) -> EventLoopFuture<Person> {
        DispatchQueue.global().async {
            do {
                let item = try JSONDecoder().decode(Person.self, from: data)
                try item.save()
                promise.succeed(item)
            } catch {
                promise.fail(error)
            }
        }

        return promise.futureResult
    }
    
    func delete(id: Int, promise: EventLoopPromise<Bool>) -> EventLoopFuture<Bool> {
        DispatchQueue.global().async {
            do {
                let row = Person()
                row.id = id
                try row.delete()
                promise.succeed(true)
            } catch {
                promise.fail(error)
            }
        }

        return promise.futureResult
    }
}
