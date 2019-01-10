//
//  PersonController.swift
//  ZenNIO-Example
//
//  Created by Gerardo Grisolini on 10/01/2019.
//

import Foundation
import ZenNIO

class PersonController {
    let personApi = ZenIoC.shared.resolve() as PersonApi
    
    init(router: Router) {
        
        router.get("/") { req, res in
            try? res.send(template: "index.html")
            res.completed()
        }
        
        router.get("/tableview.html") { req, res in
            let task = self.personApi.select(eventLoop: req.session.eventLoop)
            task.whenSuccess { items in
                let context: [String:Any] = [
                    "persons": items
                ]
                try? res.send(template: "tableview.html", context: context)
                res.completed()
            }
            task.whenFailure { error in
                print(error)
                res.completed(.internalServerError)
            }
        }
        
        router.get("/api/person") { req, res in
            let task = self.personApi.select(eventLoop: req.session.eventLoop)
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
            
            let task = self.personApi.select(id: id, eventLoop: req.session.eventLoop)
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
            
            let task = self.personApi.save(data: data, eventLoop: req.session.eventLoop)
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
            guard let data = req.bodyData else {
                res.completed(.badRequest)
                return
            }
            
            let task = self.personApi.save(data: data, eventLoop: req.session.eventLoop)
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
            
            let task = self.personApi.delete(id: id, eventLoop: req.session.eventLoop)
            task.whenSuccess { item in
                res.completed(.noContent)
            }
            task.whenFailure { error in
                print(error)
                res.completed(.internalServerError)
            }
        }
    }
}
