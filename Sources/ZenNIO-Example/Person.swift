//
//  Person.swift
//  ZenNIO-SQLite
//
//  Created by admin on 29/12/2018.
//

import Foundation
import NIO
import ZenNIO
import PerfectCRUD
import PerfectSQLite

struct Person: Codable {
    var id: UUID
    var firstName: String
    var lastName: String
    var email: String?
}

class PersonApi {
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

    func makeRoutes(router: Router) {
        router.get("/") { req, res in
            res.addHeader(.location, value: "/web/index.html")
            res.completed(.found)
        }

        router.get("/api/person") { req, res in
            let promise = req.session.eventLoop.newPromise(of: [Person].self)
            let task = personApi.selectAllPerson(promise: promise)
            task.whenSuccess { items in
                try? res.send(json: items)
                res.completed()
            }
            task.whenFailure { error in
                print(error)
                res.completed(.internalServerError)
            }
        }
        
        router.get("/api/person/:id") { req, res in
            guard let id = req.getParam(UUID.self, key: "id") else {
                res.completed(.badRequest)
                return
            }
            
            let promise = req.session.eventLoop.newPromise(of: Person?.self)
            let task = personApi.selectPerson(id: id, promise: promise)
            task.whenSuccess { item in
                try? res.send(json: item)
                res.completed()
            }
            task.whenFailure { error in
                print(error)
                res.completed(.internalServerError)
            }
        }
        
        router.post("/api/person", secure: true) { req, res in
            guard let data = req.bodyData else {
                res.completed(.badRequest)
                return
            }
            
            let promise = req.session.eventLoop.newPromise(of: Person.self)
            let task = personApi.insertPerson(data: data, promise: promise)
            task.whenSuccess { item in
                try? res.send(json: item)
                res.completed(.created)
            }
            task.whenFailure { error in
                print(error)
                res.completed(.internalServerError)
            }
        }
        
        router.put("/api/person/:id", secure: true) { req, res in
            guard let id = req.getParam(UUID.self, key: "id"), let data = req.bodyData else {
                res.completed(.badRequest)
                return
            }
            let promise = req.session.eventLoop.newPromise(of: Person.self)
            let task = personApi.updatePerson(id: id, data: data, promise: promise)
            task.whenSuccess { item in
                try? res.send(json: item)
                res.completed(.accepted)
            }
            task.whenFailure { error in
                print(error)
                res.completed(.internalServerError)
            }
        }
        
        router.delete("/api/person/:id", secure: true) { req, res in
            guard let id = req.getParam(UUID.self, key: "id") else {
                res.completed(.badRequest)
                return
            }
            let promise = req.session.eventLoop.newPromise(of: Bool.self)
            let task = personApi.deletePerson(id: id, promise: promise)
            task.whenSuccess { item in
                try? res.send(json: item)
                res.completed(.noContent)
            }
            task.whenFailure { error in
                print(error)
                res.completed(.internalServerError)
            }
        }
    }
    
    fileprivate func selectAllPerson(promise: EventLoopPromise<[Person]>) -> EventLoopFuture<[Person]> {
        do {
            let items = try db.table(Person.self)
                .order(by: \.lastName, \.firstName)
                .select()
                .map { $0 }
            promise.succeed(result: items)
        } catch {
            promise.fail(error: error)
        }
        return promise.futureResult
    }

    fileprivate func selectPerson(id: UUID, promise: EventLoopPromise<Person?>) -> EventLoopFuture<Person?> {
        do {
            let item = try db.table(Person.self)
                .where(\Person.id == id)
                .first()
            promise.succeed(result: item)
        } catch {
            promise.fail(error: error)
        }
        return promise.futureResult
    }

    fileprivate func insertPerson(data: Data, promise: EventLoopPromise<Person>) -> EventLoopFuture<Person> {
        do {
            var item = try JSONDecoder().decode(Person.self, from: data)
            item.id = UUID()
            try db.table(Person.self).insert(item)
            promise.succeed(result: item)
        } catch {
            promise.fail(error: error)
        }
        return promise.futureResult
    }

    fileprivate func updatePerson(id: UUID, data: Data, promise: EventLoopPromise<Person>) -> EventLoopFuture<Person> {
        do {
            let item = try JSONDecoder().decode(Person.self, from: data)
            try db.table(Person.self)
                .where(\Person.id == id)
                .update(item, setKeys: \.firstName, \.lastName)
            promise.succeed(result: item)
        } catch {
            promise.fail(error: error)
        }
        return promise.futureResult
    }

    fileprivate func deletePerson(id: UUID, promise: EventLoopPromise<Bool>) -> EventLoopFuture<Bool> {
        do {
            try db.table(Person.self).where(\Person.id == id).delete()
            promise.succeed(result: true)
        } catch {
            promise.fail(error: error)
        }
        return promise.futureResult
    }
}
