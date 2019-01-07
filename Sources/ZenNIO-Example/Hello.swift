//
//  Hello.swift
//  ZenNIO-Example
//
//  Created by admin on 05/01/2019.
//

import ZenNIO

class Hello {
    fileprivate let houseAnimals = ["🐶", "🐱"]
    fileprivate let farmAnimals = ["🐮", "🐔", "🐑", "🐶", "🐱"]
    fileprivate let cityAnimals = ["🐦", "🐭"]
    fileprivate var counter = 0
    
    func makeRoutes(router: Router) {
        router.get("/hello") { req, res in
            res.send(text: "Hello World!")
            res.completed()
        }
        
        router.get("/hello.html") { req, res in
            self.counter += 1

            let context: [String : Any] = [
                "name": "Animals",
                "houseAnimals": self.houseAnimals,
                "farmAnimals": self.farmAnimals,
                "cityAnimals": self.cityAnimals,
                "counter": self.counter
            ]
            do {
                try res.send(template: "hello.html", context: context)
                res.completed()
            } catch {
                print(error)
                res.completed(.internalServerError)
            }
        }
        
        router.get("/hello/:name") { req, res in
            do {
                guard let name = req.getParam(String.self, key: "name") else {
                    throw HttpError.badRequest
                }
                
                let json = [
                    "ip": req.session.ip,
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
    }
}
