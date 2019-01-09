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
//router.addCORS()
router.addAuthentication(handler: { (email, password) -> (Bool) in
    return email == "admin" && password == "admin"
})

let db = Database(configuration: try SQLiteDatabaseConfiguration("ZenNIO.db"))
ZenIoC.shared.register { PersonApi(db: db) as PersonApi }

_ = PersonController(router: router)
_ = HelloController(router: router)

let server = ZenNIO(host: "0.0.0.0", port: 8888, router: router)
server.webroot = "./webroot"

//try server.addSSL(
//    certFile: "/Users/admin/Projects/ZenNIO/cert.pem",
//    keyFile: "/Users/admin/Projects/ZenNIO/key.pem",
//    http: .v2
//)
try server.start()
