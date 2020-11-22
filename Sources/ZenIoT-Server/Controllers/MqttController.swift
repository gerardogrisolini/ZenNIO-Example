//
//  MqttController.swift
//  ZenIot
//
//  Created by Gerardo Grisolini on 10/01/2019.
//

import Foundation
import ZenNIO
import ZenIoT

func startMqttService() throws {

    let deviceApi = ZenIoC.shared.resolve() as DeviceApi
    let service = ZenIoC.shared.resolve() as MqttService

    service.onMessageReceived = { message in
        print(message.stringRepresentation!)
        
        switch message.topic {
        case "raspberry":
            if let item = try? JSONDecoder().decode(Device.self, from: message.payload) {
                deviceApi.save(item: item).whenComplete { result in
                    switch result {
                    case .success(let device):
                        print("🔴 MQTT: \(device)")
                    case .failure(let err):
                        print("⚠️ MQTT: \(err)")
                    }
                }
            }
        default:
            break
        }
    }

    try service.connect().wait()
    try service.subscribe(topic: "raspberry", qos: .atLeastOnce).wait()
}

