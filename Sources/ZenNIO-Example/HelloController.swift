//
//  HelloController.swift
//  ZenNIO-Example
//
//  Created by Gerardo Grisolini on 10/01/2019.
//

import ZenNIO
import ZenUI

func makeHelloHandlers(router: Router) {

    let houseAnimals = ["🐶", "🐱"]
    let farmAnimals = ["🐮", "🐔", "🐑", "🐶", "🐱"]
    let cityAnimals = ["🐦", "🐭"]
    var counter = 0

    router.get("/hello") { req, res in
        res.send(text: "Hello World!")
        res.completed()
    }
    
    router.get("/hello/:name") { req, res in
        do {
            guard let name: String = req.getParam("name") else {
                throw HttpError.badRequest
            }

            let json = [
                "ip": req.clientIp,
                "message": "Hello \(name)!"
            ]
            try res.send(json: json)
            res.completed()
        } catch HttpError.badRequest {
            res.completed(.badRequest)
        } catch {
            print(error)
            res.completed(.internalServerError)
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
            res.completed()
        } catch {
            print(error)
            res.completed(.internalServerError)
        }
    }
}

