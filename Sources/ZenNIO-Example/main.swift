//
//  main.swift
//  ZenNIO-Example
//
//  Created by admin on 29/12/2018.
//

import ZenNIO
import PerfectCRUD
import PerfectSQLite


let router = Router()
router.addAuthentication(handler: { (email, password) -> (Bool) in
    return email == "admin" && password == "admin"
})

let db = Database(configuration: try SQLiteDatabaseConfiguration("ZenNIO.db"))
let personApi = PersonApi(db: db)
personApi.makeRoutes(router: router)

let hello = Hello()
hello.makeRoutes(router: router)

let server = ZenNIO(host: "0.0.0.0",port: 8080, router: router)
server.webroot = "./webroot"
//try server.addSSL(
//    certFile: "/Users/admin/Projects/ZenNIO/cert.pem",
//    keyFile: "/Users/admin/Projects/ZenNIO/key.pem",
//    http: .v2
//)
try server.start()
