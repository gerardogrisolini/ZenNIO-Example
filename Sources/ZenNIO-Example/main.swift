import ZenNIO
import PerfectCRUD
import PerfectSQLite


let router = Router()
// Authentication: http://localhost:8080/auth
router.addAuthentication(handler: { (email, password) -> (Bool) in
    return email == "admin" && password == "admin"
})

let db = Database(configuration: try SQLiteDatabaseConfiguration("ZenNIO.db"))
let personApi = PersonApi(db: db)
personApi.makeRoutes(router: router)

let server = ZenNIO(port: 8080, router: router)
server.webroot = "./webroot"

do {
    try server.start()
} catch {
    print(error)
}
