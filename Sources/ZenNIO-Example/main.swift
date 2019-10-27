//
//  main.swift
//  ZenNIO-Example
//
//  Created by admin on 29/12/2018.
//

import ZenNIO
import ZenPostgres
import PostgresClientKit


/// DATABASE
var config = PostgresClientKit.ConnectionConfiguration()
config.host = "217.61.121.221"
config.database = "test"
config.user = "postgres"
config.credential = .md5Password(password: "pT4F7Ik96a")
let db = try ZenPostgres(config: config)


/// ROUTES
let router = Router()
makeHelloHandlers(router: router)
makePersonHandlers(router: router, db: db)


/// SERVER
let server = ZenNIO(host: "www.webretail.cloud", router: router)
server.addWebroot(path: "webroot")
try server.addSSL(certFile: "certificate.crt", keyFile: "private.pem", http: .v2)
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
