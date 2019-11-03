//
//  main.swift
//  ZenNIO-Example
//
//  Created by admin on 29/12/2018.
//

import ZenNIO
import ZenPostgres


/// DATABASE
let config = PostgresConfig(
    host: "localhost",
    port: 5432,
    tls: false,
    username: "gerardo",
    password: "",
    database: "zenpostgres"
)
let db = try ZenPostgres(config: config)

/// ROUTES
let router = Router()
makeHelloHandlers(router: router)
makePersonHandlers(router: router, db: db)


/// SERVER
let server = ZenNIO(router: router)
server.addWebroot()
//try server.addSSL(certFile: "certificate.crt", keyFile: "private.pem", http: .v2)
server.addAuthentication(handler: { (email, password) -> String? in
    if email == "admin" && password == "admin" {
        return "userId"
    }
    return nil
})
server.setFilter(true, methods: [.POST], url: "/api/person")
server.setFilter(true, methods: [.PUT, .DELETE], url: "/api/person/*")
//server.addCORS()
try server.start()
