//
//  PersonController.swift
//  ZenNIO-Example
//
//  Created by Gerardo Grisolini on 10/01/2019.
//

import Foundation
import ZenNIO
import ZenPostgres
import Logging

func makePersonHandlers() {
    
    let personApi = PersonApi()    
    let router = ZenIoC.shared.resolve() as Router
    
    router.get("/") { req, res in
        res.addHeader(.location, value: "/index.html")
        res.success(.found)
    }
    
    router.get("/table.html") { req, res in
        let task = personApi.select()
        task.whenSuccess { items in
            let context: [String : Any] = [
                "rows": items
            ]
            try? res.send(template: "table.html", context: context)
            res.success()
        }
        task.whenFailure { error in
            res.failure(.internalError(error.localizedDescription))
        }
    }
    
    
    /// REST API
    
    router.get("/api/person") { req, res in
        let task = personApi.select()
        task.whenSuccess { items in
            try? res.send(json: items)
            res.success()
        }
        task.whenFailure { error in
            res.failure(.internalError(error.localizedDescription))
        }
    }
    
    router.get("/api/person/:id") { req, res in
        guard let id: Int = req.getParam("id") else {
            res.failure(.badRequest("parameter id"))
            return
        }
        
        let task = personApi.select(id: id)
        task.whenSuccess { item in
            try? res.send(json: item)
            res.success()
        }
        task.whenFailure { error in
            res.failure(.internalError(error.localizedDescription))
        }
    }
    
    router.post("/api/person") { req, res in
        guard let data = req.bodyData,
            let item = try? JSONDecoder().decode(Person.self, from: data) else {
            res.failure(.badRequest("data on body"))
            return
        }
        
        let task = personApi.save(item: item)
        task.whenSuccess { item in
            try? res.send(json: item)
            res.success(.created)
        }
        task.whenFailure { error in
            res.failure(.internalError(error.localizedDescription))
        }
    }
    
    router.put("/api/person") { req, res in
        guard let data = req.bodyData,
            let item = try? JSONDecoder().decode(Person.self, from: data) else {
            res.failure(.badRequest("data on body"))
            return
        }
        
        let task = personApi.save(item: item)
        task.whenSuccess { item in
            try? res.send(json: item)
            res.success(.accepted)
        }
        task.whenFailure { error in
            res.failure(.internalError(error.localizedDescription))
        }
    }
    
    router.delete("/api/person/:id") { req, res in
        guard let id: Int = req.getParam("id") else {
            res.failure(.badRequest("parameter id"))
            return
        }
        
        let task = personApi.delete(id: id)
        task.whenSuccess { item in
            res.success(.noContent)
        }
        task.whenFailure { error in
            res.failure(.internalError(error.localizedDescription))
        }
    }
}

