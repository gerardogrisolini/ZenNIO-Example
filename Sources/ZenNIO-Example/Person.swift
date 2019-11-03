//
//  Person.swift
//  ZenNIO-Example
//
//  Created by admin on 29/12/2018.
//

import Foundation
import PostgresKit
import ZenPostgres

class Person: PostgresTable, Codable {
    var id: Int = 0
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""

    private enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case email
    }

    required init() {
        super.init()
        self.tableIndexes.append("email")
    }

    override func decode(row: PostgresRow) {
        id = row.column("id")?.int ?? id
        firstName = row.column("firstName")?.string ?? firstName
        lastName = row.column("lastName")?.string ?? lastName
        email = row.column("email")?.string ?? email
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        email = try container.decode(String.self, forKey: .email)
   }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
    }
}
