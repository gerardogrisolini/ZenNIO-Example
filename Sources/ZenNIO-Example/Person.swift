//
//  Person.swift
//  ZenNIO-Example
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
            let task = personApi.selectAllPerson(eventLoop: req.session.eventLoop)
            task.whenSuccess { items in
                let context: [String:Any] = [
                    "persons": items
                ]
                try? res.send(template: "person.html", context: context)
                res.completed()
            }
            task.whenFailure { error in
                print(error)
                res.completed(.internalServerError)
            }
        }

        router.get("/api/person") { req, res in
            let task = personApi.selectAllPerson(eventLoop: req.session.eventLoop)
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
            
            let task = personApi.selectPerson(id: id, eventLoop: req.session.eventLoop)
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
            
            let task = personApi.insertPerson(data: data, eventLoop: req.session.eventLoop)
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
            
            let task = personApi.updatePerson(id: id, data: data, eventLoop: req.session.eventLoop)
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
            
            let task = personApi.deletePerson(id: id, eventLoop: req.session.eventLoop)
            task.whenSuccess { item in
                res.completed(.noContent)
            }
            task.whenFailure { error in
                print(error)
                res.completed(.internalServerError)
            }
        }
    }
    
    fileprivate func selectAllPerson(eventLoop: EventLoop) -> EventLoopFuture<[Person]> {
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

    fileprivate func selectPerson(id: UUID, eventLoop: EventLoop) -> EventLoopFuture<Person?> {
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

    fileprivate func insertPerson(data: Data, eventLoop: EventLoop) -> EventLoopFuture<Person> {
        let promise = eventLoop.newPromise(of: Person.self)
        eventLoop.execute {
            do {
                var item = try JSONDecoder().decode(Person.self, from: data)
                item.id = UUID()
                try self.db.table(Person.self).insert(item)
                promise.succeed(result: item)
            } catch {
                promise.fail(error: error)
            }
        }
        return promise.futureResult
    }

    fileprivate func updatePerson(id: UUID, data: Data, eventLoop: EventLoop) -> EventLoopFuture<Person> {
        let promise = eventLoop.newPromise(of: Person.self)
        eventLoop.execute {
            do {
                let item = try JSONDecoder().decode(Person.self, from: data)
                try self.db.table(Person.self)
                    .where(\Person.id == id)
                    .update(item, setKeys: \.firstName, \.lastName)
                promise.succeed(result: item)
            } catch {
                promise.fail(error: error)
            }
        }
        return promise.futureResult
    }

    fileprivate func deletePerson(id: UUID, eventLoop: EventLoop) -> EventLoopFuture<Bool> {
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
