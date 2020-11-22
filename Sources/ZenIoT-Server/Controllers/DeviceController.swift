//
//  DeviceController.swift
//  ZenIot
//
//  Created by Gerardo Grisolini on 10/01/2019.
//

import Foundation
import ZenNIO
import ZenPostgres
import ZenIoT

func makeRoutesAndHandlers() {
    
    let deviceApi = DeviceApi()
    ZenIoC.shared.register { deviceApi as DeviceApi }
    let router = ZenIoC.shared.resolve() as Router
    
    router.get("/") { req, res in
        res.addHeader(.location, value: "/index.html")
        res.success(.found)
    }
    
    /// REST API
    
    router.get("/api/device") { req, res in
        let task = deviceApi.select()
        task.whenSuccess { items in
            try? res.send(json: items)
            res.success()
        }
        task.whenFailure { error in
            res.failure(.internalError(error.localizedDescription))
        }
    }
    
    router.get("/api/device/:id") { req, res in
        guard let id: Int = req.getParam("id") else {
            res.failure(.badRequest("parameter id"))
            return
        }
        
        let task = deviceApi.select(id: id)
        task.whenSuccess { item in
            try? res.send(json: item)
            res.success()
        }
        task.whenFailure { error in
            res.failure(.internalError(error.localizedDescription))
        }
    }
    
    router.post("/api/device") { req, res in
        guard let data = req.bodyData,
            let item = try? JSONDecoder().decode(Device.self, from: data) else {
            return res.failure(.badRequest("data on body"))
        }
        
        let task = deviceApi.save(item: item)
        task.whenSuccess { item in
            try? res.send(json: item)
            res.success(.created)
        }
        task.whenFailure { error in
            res.failure(.internalError(error.localizedDescription))
        }
    }
    
    router.put("/api/device") { req, res in
        guard let data = req.bodyData,
            let item = try? JSONDecoder().decode(Device.self, from: data) else {
            res.failure(.badRequest("data on body"))
            return
        }
        
        let task = deviceApi.save(item: item)
        task.whenSuccess { item in
            try? res.send(json: item)
            res.success(.accepted)
        }
        task.whenFailure { error in
            res.failure(.internalError(error.localizedDescription))
        }
    }
    
    router.delete("/api/device/:id") { req, res in
        guard let id: Int = req.getParam("id") else {
            res.failure(.badRequest("parameter id"))
            return
        }
        
        let task = deviceApi.delete(id: id)
        task.whenSuccess { item in
            res.success(.noContent)
        }
        task.whenFailure { error in
            res.failure(.internalError(error.localizedDescription))
        }
    }
    
    
    /// Commands
    
    router.post("/api/device/:macAddress") { req, res in
        guard let macAddress: String = req.getParam("macAddress"),
              let data = req.bodyData,
              let item = try? JSONDecoder().decode(DeviceAction.self, from: data) else {
            res.failure(.badRequest("data on body"))
            return
        }
        
        let service = ZenIoC.shared.resolve() as MqttService
        let task = service.publish(topic: "raspberry.\(macAddress)", payload: item)
        task.whenSuccess { item in
            res.success(.noContent)
        }
        task.whenFailure { error in
            res.failure(.internalError(error.localizedDescription))
        }
    }
}

