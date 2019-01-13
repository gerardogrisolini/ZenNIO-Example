//
//  PersonApi.swift
//  ZenNIO-Example
//
//  Created by Gerardo Grisolini on 10/01/2019.
//

import Foundation
import NIO
import PerfectCRUD
import PerfectSQLite

class PersonApi : TableApi {

    private let db: Database<SQLiteDatabaseConfiguration>
    
    init(db: Database<SQLiteDatabaseConfiguration>) {
        self.db = db
        do {
            let table = try db.create(Person.self, primaryKey: \.id, policy: .reconcileTable)
            try table.index(\.lastName)
            try table.index(unique: true, \.email)
        } catch {
            print(error)
        }
    }
    
    func select(eventLoop: EventLoop) -> EventLoopFuture<[Person]> {
        let promise = eventLoop.newPromise(of: [Person].self)
        eventLoop.execute {
            do {
                let items = try self.db.table(Person.self)
                    .order(by: \.lastName, \.firstName)
                    .select()
                    .map { $0 }
                promise.succeed(result: items)
            } catch {
                promise.fail(error: error)
            }
        }
        return promise.futureResult
    }
    
    func select(id: UUID, eventLoop: EventLoop) -> EventLoopFuture<Person?> {
        let promise = eventLoop.newPromise(of: Person?.self)
        eventLoop.execute {
            do {
                let item = try self.db.table(Person.self)
                    .where(\Person.id == id)
                    .first()
                promise.succeed(result: item)
            } catch {
                promise.fail(error: error)
            }
        }
        return promise.futureResult
    }
    
    func save(data: Data, eventLoop: EventLoop) -> EventLoopFuture<Person> {
        let promise = eventLoop.newPromise(of: Person.self)
        eventLoop.execute {
            do {
                var item = try JSONDecoder().decode(Person.self, from: data)
                if item.id.uuidString == "00000000-0000-0000-0000-000000000000" {
                    item.id = UUID()
                    try self.db.table(Person.self).insert(item)
                } else {
                    try self.db.table(Person.self)
                        .where(\Person.id == item.id)
                        .update(item, setKeys: \.firstName, \.lastName, \.email)
                }
                promise.succeed(result: item)
            } catch {
                promise.fail(error: error)
            }
        }
        return promise.futureResult
    }
    
    func delete(id: UUID, eventLoop: EventLoop) -> EventLoopFuture<Bool> {
        let promise = eventLoop.newPromise(of: Bool.self)
        eventLoop.execute {
            do {
                try self.db.table(Person.self).where(\Person.id == id).delete()
                promise.succeed(result: true)
            } catch {
                promise.fail(error: error)
            }
        }
        return promise.futureResult
    }
}
