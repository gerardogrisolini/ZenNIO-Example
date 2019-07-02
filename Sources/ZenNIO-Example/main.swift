//
//  main.swift
//  ZenNIO-Example
//
//  Created by admin on 29/12/2018.
//

import ZenNIO
import ZenPostgres

let config = PostgresConfig(
    host: "zenretail-db.westeurope.cloudapp.azure.com",
    port: 5433,
    tls: false,
    username: "postgres",
    password: "PwjwdwaEKk",
    database: "tessilnova"
)
let db = try ZenPostgres(config: config)
ZenIoC.shared.register { PersonApi(db: db) as PersonApi }

let router = Router()
_ = PersonController(router: router)
_ = HelloController(router: router)

let server = ZenNIO(router: router)
server.addWebroot(path: "webroot")
server.addAuthentication(handler: { (email, password) -> String? in
    if email == "admin" && password == "admin" {
        return "userId"
    }
    return nil
})
server.setFilter(true, methods: [.POST], url: "/api/person")
server.setFilter(true, methods: [.PUT], url: "/api/person/*")
server.setFilter(true, methods: [.DELETE], url: "/api/person/*")
//server.addCORS()
//try server.addSSL(
//    certFile: "/Users/admin/Projects/ZenNIO/cert.pem",
//    keyFile: "/Users/admin/Projects/ZenNIO/key.pem",
//    http: .v2
//)
try server.start()
