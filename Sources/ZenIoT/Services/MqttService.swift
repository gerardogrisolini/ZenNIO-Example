//
//  MqttService.swift
//  
//
//  Created by Gerardo Grisolini on 21/11/20.
//

import Foundation
import NIO
import ZenMQTT

public class MqttService {

    private let username: String?
    private let password: String?
    private let keepAlive: UInt16
    private let mqtt: ZenMQTT
    private let eventLoopGroup: EventLoopGroup
    public var onMessageReceived: MQTTMessageReceived = { _ in }
    
    public init(
        host: String,
        port: Int = 1883,
        username: String? = nil,
        password: String? = nil,
        certFile: String? = nil,
        keyFile: String? = nil,
        keepAlive: UInt16 = 20,
        eventLoopGroup: EventLoopGroup
    ) {
        self.username = username
        self.password = password
        self.keepAlive = keepAlive
        self.eventLoopGroup = eventLoopGroup
        
        mqtt = ZenMQTT(
            host: host,
            port: port,
            clientID: "WECYOU_DEVICE_\(Date().timeIntervalSinceNow)",
            reconnect: true,
            eventLoopGroup: eventLoopGroup
        )
       
        if let cert = certFile, let key = keyFile {
            try? mqtt.addTLS(cert: cert, key: key)
        }
        
        mqtt.onHandlerRemoved = {
            print("🔴 MQTT Handler removed")
        }
        mqtt.onErrorCaught = { error in
            print("⚠️ MQTT: \(error)")
        }
    }

    public func connect() -> EventLoopFuture<Void> {
        mqtt.onMessageReceived = onMessageReceived

        return mqtt.connect(username: username, password: password, keepAlive: keepAlive)
            .map { () -> () in
                print("▶️ MQTT connected")
            }
            .flatMapError { error -> EventLoopFuture<Void> in
                print("⚠️ MQTT: \(error)")
                sleep(3)
                return self.connect()
            }
    }
    
    public func disconnect() -> EventLoopFuture<Void> {
        return self.mqtt.disconnect().map { () -> () in
            print("⏹️ MQTT disconnected")
        }
    }
    
    public func unsubscribe(topic: String) -> EventLoopFuture<Void> {
        return self.mqtt.unsubscribe(
            from : [topic]
        ).map { () -> () in
            print("🔕 MQTT unsubscribe: \(topic)")
        }
    }

    public func subscribe(topic: String, qos: MQTTQoS) -> EventLoopFuture<Void> {
        var param = [String : MQTTQoS]()
        param[topic] = qos

        return self.mqtt.subscribe(
            to : param
        ).map { () -> () in
            print("🔔 MQTT subscribe: \(topic)")
        }
    }

    private func publish(topic: String, payload: Data) -> EventLoopFuture<Void> {
        let message = MQTTPubMsg(topic: topic, payload: payload, retain: false, QoS: .atLeastOnce)
        return mqtt.publish(message: message).map { () -> () in
            print("💬 MQTT Notification: \(message)")
        }.flatMapError { error -> EventLoopFuture<()> in
            print("⚠️ MQTT: \(error)")
            return self.eventLoopGroup.next().makeFailedFuture(error)
        }
    }
    
    public func publish<T: Encodable>(topic: String, payload: T) -> EventLoopFuture<Void> {
        let data = try! JSONEncoder().encode(payload)
        return publish(topic: topic, payload: data)
    }
}
