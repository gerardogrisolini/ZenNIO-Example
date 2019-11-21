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


/// SERVER
let server = ZenNIO()
server.logger.logLevel = .trace
server.addWebroot()

/// DATABASE
let config = PostgresConfig(
    host: "localhost",
    port: 5432,
    tls: false,
    username: "gerardo",
    password: "",
    database: "zenpostgres",
    logger: server.logger
)
ZenPostgres.pool.setup(config: config, eventLoopGroup: server.eventLoopGroup)

/// ROUTES AND HANDLERS
makeHelloHandlers()
makePersonHandlers()

/// AUTHENTICATION AND FILTERS
server.addAuthentication(handler: { (email, password) -> EventLoopFuture<String> in
    var userId = ""
    if email == "admin" && password == "admin" {
        userId = "userId"
    }
    return server.eventLoopGroup.future(userId)
})
server.setFilter(true, methods: [.POST, .PUT], url: "/api/person")
server.setFilter(true, methods: [.DELETE], url: "/api/person/*")

/// RUN
try server.start()
