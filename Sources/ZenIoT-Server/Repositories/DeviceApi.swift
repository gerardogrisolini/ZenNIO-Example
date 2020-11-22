//
//  DeviceApi.swift
//  ZenIot
//
//  Created by Gerardo Grisolini on 10/01/2019.
//

import NIO
import ZenIoT
import ZenPostgres

class DeviceApi : ApiProtocol {
    
    init() {
        try? setup().wait()
    }
    
    private func setup() -> EventLoopFuture<Void> {
        return ZenPostgres.pool.connect().flatMap { conn -> EventLoopFuture<Void> in
            defer { conn.disconnect() }
            
            return Device(connection: conn).create().map { () -> () in
                ()
            }
        }
    }
    
    func select() -> EventLoopFuture<[Device]> {
        return Device().query(orderby: ["name"])
    }
    
    func select(id: Int) -> EventLoopFuture<Device> {
        let item = Device()
        return item.get(id).map { () -> Device in
            item
        }
    }
    
    func save(item: Device) -> EventLoopFuture<Device> {
        return item
            .query(whereclause: "macAddress = $1", params: [item.macAddress])
            .flatMap { (rows: [Device]) -> EventLoopFuture<Device> in
            
            if let row = rows.first {
                item.id = row.id
            }
            return item.save().map { id -> Device in
                item.id = id as! Int
                return item
            }
        }
    }
    
    func delete(id: Int) -> EventLoopFuture<Bool> {
        return Device().delete(id)
    }
}
