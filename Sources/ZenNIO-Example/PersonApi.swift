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
        self.db.connectAsync { conn in
            switch conn {
            case .success(let connection):
                Person(connection: connection).queryAsync(orderby: ["lastName", "firstName"]) { result in
                    switch result {
                    case .success(let rows):
                        promise.succeed(rows)
                    case .failure(let error):
                        promise.fail(error)
                    }
                    connection.disconnect()
                }
            case .failure(let err):
                promise.fail(err)
            }
        }
        
        return promise.futureResult
    }
    
    func select(id: Int, promise: EventLoopPromise<Person?>) -> EventLoopFuture<Person?> {
        self.db.connectAsync { conn in
            switch conn {
            case .success(let connection):
                Person(connection: connection).getAsync(id) { result in
                    switch result {
                    case .success(let row):
                        promise.succeed(row)
                    case .failure(let error):
                        promise.fail(error)
                    }
                    connection.disconnect()
                }
            case .failure(let err):
                promise.fail(err)
            }
        }
        
        return promise.futureResult
    }
    
    func insert(data: Data, promise: EventLoopPromise<Person>) -> EventLoopFuture<Person> {
        do {
            let item = try JSONDecoder().decode(Person.self, from: data)
            
            self.db.connectAsync { conn in
                switch conn {
                case .success(let connection):
                    item.connection = connection
                    item.saveAsync { id in
                        item.id = id as! Int
                        promise.succeed(item)
                        connection.disconnect()
                    }
                case .failure(let err):
                    promise.fail(err)
                }
            }
        } catch {
            promise.fail(error)
        }
        
        return promise.futureResult
    }

    func update(data: Data, promise: EventLoopPromise<Person>) -> EventLoopFuture<Person> {
        do {
            let item = try JSONDecoder().decode(Person.self, from: data)

            self.db.connectAsync { conn in
                switch conn {
                case .success(let connection):
                    item.connection = connection
                    item.saveAsync { _ in
                        promise.succeed(item)
                        connection.disconnect()
                    }
                case .failure(let err):
                    promise.fail(err)
                }
            }
        } catch {
            promise.fail(error)
        }
        
        return promise.futureResult
    }
    
    func delete(id: Int, promise: EventLoopPromise<Bool>) -> EventLoopFuture<Bool> {
        self.db.connectAsync { conn in
            switch conn {
            case .success(let connection):
                Person(connection: connection).deleteAsync(id) { result in
                    switch result {
                    case .success(let count):
                        promise.succeed(count > 0)
                    case .failure(let error):
                        promise.fail(error)
                    }
                    connection.disconnect()
                }
            case .failure(let err):
                promise.fail(err)
            }
        }

        return promise.futureResult
    }
}
