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
    
    router.get("/table.html") { req, res in
        req.eventLoop.execute {
            do {
                let context: [String : Any] = [
                    "rows": try personApi.select()
                ]
                try res.send(template: "table.html", context: context)
                res.completed()
            } catch {
                res.completed(.internalServerError)
            }
        }
    }
    
    router.get("/api/person") { req, res in
        req.eventLoop.execute {
            do {
                let items = try personApi.select()
                try res.send(json: items)
                res.completed()
            } catch {
                res.completed(.internalServerError)
            }
        }
    }
    
    router.get("/api/person/:id") { req, res in
        guard let id: Int = req.getParam("id") else {
            res.completed(.badRequest)
            return
        }
        
        req.eventLoop.execute {
            do {
                let item = try personApi.select(id: id)
                try res.send(json: item)
                res.completed()
            } catch {
                res.completed(.internalServerError)
            }
        }
    }
    
    router.post("/api/person") { req, res in
        guard let data = req.bodyData else {
            res.completed(.badRequest)
            return
        }
        
        req.eventLoop.execute {
            do {
                let item = try personApi.insert(data: data)
                try res.send(json: item)
                res.completed(.created)
            } catch {
                res.completed(.internalServerError)
            }
        }
    }
    
    router.put("/api/person/:id") { req, res in
        guard let data = req.bodyData else {
            res.completed(.badRequest)
            return
        }
        
        req.eventLoop.execute {
            do {
                try personApi.update(data: data)
                res.completed(.accepted)
            } catch {
                res.completed(.notModified)
            }
        }
    }
    
    router.delete("/api/person/:id") { req, res in
        guard let id: Int = req.getParam("id") else {
            res.completed(.badRequest)
            return
        }
        
        req.eventLoop.execute {
            do {
                try personApi.delete(id: id)
                res.completed(.noContent)
            } catch {
                res.completed(.internalServerError)
            }
        }
    }
}

