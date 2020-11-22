//
//  DeviceModel.swift
//  ZenIot
//
//  Created by admin on 29/12/2018.
//

import Foundation

public class DeviceModel: Codable {
    
    public var id: Int = 0
    public var name: String = ""
    public let macAddress: String
    public var system: String = ""
    public var version: String = ""
    public var info: DeviceInfo = DeviceInfo()
    
    public init(macAddress: String) {
        self.macAddress = macAddress
    }
}
