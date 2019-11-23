//
//  HelloController.swift
//  ZenNIO-Example
//
//  Created by Gerardo Grisolini on 10/01/2019.
//

import ZenNIO
import ZenUI

func makeHelloHandlers() {

    let router = ZenIoC.shared.resolve() as Router
    
    let houseAnimals = ["🐶", "🐱"]
    let farmAnimals = ["🐮", "🐔", "🐑", "🐶", "🐱"]
    let cityAnimals = ["🐦", "🐭"]
    var counter = 0

    router.get("/hello") { req, res in
        res.send(text: "Hello World!")
        res.success()
    }
    
    router.get("/hello/:name") { req, res in
        guard let name: String = req.getParam("name") else {
            res.failure(.badRequest("parameter name"))
            return
        }

        do {
            let json = [
                "ip": req.clientIp,
                "message": "Hello \(name)!"
            ]
            try res.send(json: json)
            res.success()
        } catch {
            res.failure(.internalError(error.localizedDescription))
        }
    }
    
    router.get("/hello.html") { req, res in
        counter += 1
        
        let context: [String : Any] = [
            "name": "Animals",
            "houseAnimals": houseAnimals,
            "farmAnimals": farmAnimals,
            "cityAnimals": cityAnimals,
            "counter": counter
        ]
        do {
            try res.send(template: "hello.html", context: context)
            res.success()
        } catch {
            res.failure(.internalError(error.localizedDescription))
        }
    }
}

