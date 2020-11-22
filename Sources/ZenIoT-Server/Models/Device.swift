//
//  Device.swift
//  
//
//  Created by Gerardo Grisolini on 21/11/20.
//

import Foundation
import PostgresNIO
import ZenPostgres
import ZenIoT

class Device: PostgresTable, Codable {
    
    public var id: Int = 0
    public var name: String = ""
    public var macAddress: String = ""
    public var system: String = ""
    public var version: String = ""
    public var info: DeviceInfo = DeviceInfo()

    required init() {
        super.init()
        self.tableIndexes.append("macAddress")
    }

    public override func decode(row: PostgresRow) {
        id = row.column("id")?.int ?? id
        name = row.column("name")?.string ?? name
        macAddress = row.column("macAddress")?.string ?? macAddress
        system = row.column("system")?.string ?? system
        version = row.column("version")?.string ?? version
        if let data = row.column("info")?.jsonb {
            info = try! JSONDecoder().decode(DeviceInfo.self, from: data)
        }
    }
}
