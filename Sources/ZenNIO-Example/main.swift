//
//  main.swift
//  ZenNIO-Example
//
//  Created by admin on 29/12/2018.
//

import NIO
import ZenNIO
import ZenPostgres
import Logging

/// LOGGER
var logger = Logger(label: "ZenNIO-Example")
logger.logLevel = .trace

/// SERVER
let server = ZenNIO(logger: logger)
server.addWebroot()

/// ROUTES AND HANDLERS
makeHelloHandlers()
makePersonHandlers()

/// AUTHENTICATION
server.addAuthentication(handler: { (email, password) -> EventLoopFuture<String> in
    var userId = ""
    if email == "admin" && password == "admin" {
        userId = "userId"
    }
    return server.eventLoopGroup.future(userId)
})

/// FILTERS
server.setFilter(true, methods: [.POST, .PUT], url: "/api/person")
server.setFilter(true, methods: [.DELETE], url: "/api/person/*")

/// DATABASE
let config = PostgresConfig(
    host: "localhost",
    port: 5432,
    tls: false,
    username: "gerardo",
    password: "",
    database: "zenpostgres",
    logger: logger
)
_ = ZenPostgres(config: config, eventLoopGroup: server.eventLoopGroup)

/// RUN
try server.start()
