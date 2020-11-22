//
//  main.swift
//  ZenIot-Server
//
//  Created by Gerardo Grisolini on 21/11/20.
//

import Foundation
import NIO
import ZenNIO
import ZenPostgres
import ZenIoT


/// SERVER
let server = ZenNIO()
server.logger.logLevel = .trace
server.addDocs()

/// AUTHENTICATION
server.addAuthentication(handler: { (email, password) -> EventLoopFuture<String> in
    var userId = ""
    if email == "admin" && password == "admin" {
        userId = "userId"
    }
    return server.eventLoopGroup.future(userId)
})

/// DATABASE
let config = parseConnectionStringDatabase()
ZenPostgres.pool.setup(config: config, eventLoopGroup: server.eventLoopGroup)

makeRoutesAndHandlers()

/// MQTT
if let service = parseConnectionStringMqtt() {
    ZenIoC.shared.register { service as MqttService }
    defer {
        try? service.unsubscribe(topic: "raspberry").wait()
        try? service.disconnect().wait()
    }
    try startMqttService()

    /// FILTERS
    server.setFilter(true, methods: [.GET, .POST, .PUT, .DELETE], url: "/api/*")
    server.setFilter(false, methods: [.POST], url: "/api/login")

    /// START SERVER
    try server.start()
}


/// PARSE CONNECTIONS FROM ENV
private func parseConnectionStringDatabase() -> PostgresConfig {
    if let databaseUrl = ProcessInfo.processInfo.environment["DATABASE_URL"] {
        var url = databaseUrl.replacingOccurrences(of: "postgres://", with: "")
        var index = url.index(before: url.firstIndex(of: ":")!)
        let username = url[url.startIndex...index].description
        
        index = url.index(index, offsetBy: 2)
        var index2 = url.index(before: url.firstIndex(of: "@")!)
        let password = url[index...index2].description
        
        index = url.index(index2, offsetBy: 2)
        url = url[index...].description
        
        index2 = url.index(before: url.firstIndex(of: ":")!)
        let host = url[url.startIndex...index2].description
        
        index = url.index(index2, offsetBy: 2)
        index2 = url.index(before: url.firstIndex(of: "/")!)
        let port = Int(url[index...index2].description)!
        
        index = url.index(index2, offsetBy: 2)
        let database = url[index...].description

        return PostgresConfig(
            host: host,
            port: port,
            tls: true,
            username: username,
            password: password,
            database: database,
            maximumConnections: 10,
            logger: server.logger
        )
    }

    return PostgresConfig(
        host: "localhost",
        port: 5432,
        tls: false,
        username: "gerardo",
        password: "",
        database: "mqtt",
        maximumConnections: 10,
        logger: server.logger
    )
}

private func parseConnectionStringMqtt() -> MqttService? {
//    if let mqttUrl = ProcessInfo.processInfo.environment["CLOUDAMQP_URL"] {
    let mqttUrl = "amqps://tmhtseai:Elpycwnwdx5ZZoxMvP49kcSNmG8zl3q9@squid.rmq.cloudamqp.com/tmhtseai"
    
        let url = mqttUrl.replacingOccurrences(of: "amqps://", with: "")
        var index = url.index(before: url.firstIndex(of: ":")!)
        var username = url[url.startIndex...index].description
        
        index = url.index(index, offsetBy: 2)
        var index2 = url.index(before: url.firstIndex(of: "@")!)
        let password = url[index...index2].description
        
        index = url.index(index2, offsetBy: 2)
        index2 = url.index(before: url.lastIndex(of: "/")!)
        let host = url[index...index2].description
        index2 = url.index(index2, offsetBy: 2)
        username += ":\(url[index2...])"
       
        return MqttService(host: host, username: username, password: password, eventLoopGroup: server.eventLoopGroup)
//    }
//
//    return nil
}
