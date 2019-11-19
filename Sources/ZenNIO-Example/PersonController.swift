//
//  PersonController.swift
//  ZenNIO-Example
//
//  Created by Gerardo Grisolini on 10/01/2019.
//

import Foundation
import ZenNIO
import ZenPostgres

func makePersonHandlers() {
    
    let personApi = ZenIoC.shared.resolve() as PersonApi
    let router = ZenIoC.shared.resolve() as Router

    router.get("/") { req, res in
        res.addHeader(.location, value: "/index.html")
        res.completed(.found)
    }
    
    router.get("/table.html") { req, res in
        let task = personApi.select()
        task.whenSuccess { items in
            let context: [String : Any] = [
                "rows": items
            ]
            try? res.send(template: "table.html", context: context)
            res.completed()
        }
        task.whenFailure { error in
            print(error)
            res.completed(.internalServerError)
        }
    }
    
    
    /// REST API
    
    router.get("/api/person") { req, res in
        let task = personApi.select()
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
        
        let task = personApi.select(id: id)
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
        guard let data = req.bodyData,
            let item = try? JSONDecoder().decode(Person.self, from: data) else {
            res.completed(.badRequest)
            return
        }
        
        let task = personApi.save(item: item)
        task.whenSuccess { item in
            try? res.send(json: item)
            res.completed(.created)
        }
        task.whenFailure { error in
            print(error)
            res.completed(.internalServerError)
        }
    }
    
    router.put("/api/person") { req, res in
        guard let data = req.bodyData,
            let item = try? JSONDecoder().decode(Person.self, from: data) else {
            res.completed(.badRequest)
            return
        }
        
        let task = personApi.save(item: item)
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
        
        let task = personApi.delete(id: id)
        task.whenSuccess { item in
            res.completed(.noContent)
        }
        task.whenFailure { error in
            print(error)
            res.completed(.internalServerError)
        }
    }
}

