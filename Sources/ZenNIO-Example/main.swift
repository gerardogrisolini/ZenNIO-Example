//
//  main.swift
//  ZenNIO-Example
//
//  Created by admin on 29/12/2018.
//

import ZenNIO
import PerfectCRUD
import PerfectSQLite


let db = Database(configuration: try SQLiteDatabaseConfiguration("ZenNIO.db"))
ZenIoC.shared.register { PersonApi(db: db) as PersonApi }

let router = Router()
_ = PersonController(router: router)
_ = HelloController(router: router)

let server = ZenNIO(router: router)
server.addWebroot(path: "webroot")
server.addAuthentication(handler: { (email, password) -> (Bool) in
    return email == "admin" && password == "admin"
})
server.addFilter(method: .POST, url: "/api/person")
server.addFilter(method: .PUT, url: "/api/person/*")
server.addFilter(method: .DELETE, url: "/api/person/*")
//server.addCORS()
//try server.addSSL(
//    certFile: "/Users/admin/Projects/ZenNIO/cert.pem",
//    keyFile: "/Users/admin/Projects/ZenNIO/key.pem",
//    http: .v2
//)
try server.start()
