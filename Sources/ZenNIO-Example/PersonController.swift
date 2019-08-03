//
//  PersonController.swift
//  ZenNIO-Example
//
//  Created by Gerardo Grisolini on 10/01/2019.
//

import Foundation
import ZenNIO
import ZenPostgres

func makePersonHandlers(router: Router, db: Database) {
    
    let personApi = PersonApi(db: db)
    
    router.get("/") { req, res in
        res.addHeader(.location, value: "/index.html")
        res.completed(.found)
    }
    
    router.get("/api/person") { req, res in
        let promise = req.eventLoop.makePromise(of: [Person].self)
        let task = personApi.select(promise: promise)
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
        guard let id: Int = req.getParam("id") else {
            res.completed(.badRequest)
            return
        }
        
        let promise = req.eventLoop.makePromise(of: Person?.self)
        let task = personApi.select(id: id, promise: promise)
        task.whenSuccess { item in
            try? res.send(json: item)
            res.completed()
        }
        task.whenFailure { error in
            print(error)
            res.completed(.internalServerError)
        }
    }
    
    router.post("/api/person") { req, res in
        guard let data = req.bodyData else {
            res.completed(.badRequest)
            return
        }
        
        let promise = req.eventLoop.makePromise(of: Person.self)
        let task = personApi.insert(data: data, promise: promise)
        task.whenSuccess { item in
            try? res.send(json: item)
            res.completed(.created)
        }
        task.whenFailure { error in
            print(error)
            res.completed(.internalServerError)
        }
    }
    
    router.put("/api/person/:id") { req, res in
        guard let data = req.bodyData else {
            res.completed(.badRequest)
            return
        }
        
        let promise = req.eventLoop.makePromise(of: Person.self)
        let task = personApi.update(data: data, promise: promise)
        task.whenSuccess { item in
            try? res.send(json: item)
            res.completed(.accepted)
        }
        task.whenFailure { error in
            print(error)
            res.completed(.internalServerError)
        }
    }
    
    router.delete("/api/person/:id") { req, res in
        guard let id: Int = req.getParam("id") else {
            res.completed(.badRequest)
            return
        }
        
        let promise = req.eventLoop.makePromise(of: Bool.self)
        let task = personApi.delete(id: id, promise: promise)
        task.whenSuccess { item in
            res.completed(.noContent)
        }
        task.whenFailure { error in
            print(error)
            res.completed(.internalServerError)
        }
    }
}

