//
//  main.swift
//  ZenNIO-Example
//
//  Created by admin on 29/12/2018.
//

import NIO
import ZenNIO
import ZenPostgres


/// DEPENDENCY INJECTION
ZenIoC.shared.register { PersonApi() }

/// ROUTES AND HANDLERS
let router = Router()
makeHelloHandlers(router: router)
makePersonHandlers(router: router)

/// SERVER
let server = ZenNIO(router: router)
server.addWebroot()
//server.addCORS()

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
    database: "zenpostgres"
)
_ = ZenPostgres(config: config, eventLoopGroup: server.eventLoopGroup)

/// RUN
try server.start()
