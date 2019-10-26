//
//  PersonApi.swift
//  ZenNIO-Example
//
//  Created by Gerardo Grisolini on 10/01/2019.
//

import Foundation
import NIO
import ZenPostgres


class PersonApi : ApiProtocol {

    private let db: Database
    
    init(db: Database) {
        self.db = db
        do {
            try Person().create()
        } catch {
            print(error)
        }
    }
    
    func select() throws -> [Person] {
        let db = try self.db.connect()
        defer { db.disconnect() }
        return try Person(db: db).query(orderby: ["lastName", "firstName"])
    }
    
    func select(id: Int) throws -> Person? {
        let db = try self.db.connect()
        defer { db.disconnect() }
        do {
            let row = Person(db: db)
            try row.get(id)
            return row
        } catch {
            return nil
        }
    }
    
    func insert(data: Data) throws -> Person {
        let item = try JSONDecoder().decode(Person.self, from: data)
        try item.save { id in
            item.id = id as! Int
        }
        return item
    }

    func update(data: Data) throws {
        let item = try JSONDecoder().decode(Person.self, from: data)
        try item.save()
    }
    
    func delete(id: Int) throws {
        let row = Person()
        row.id = id
        try row.delete()
    }
}
