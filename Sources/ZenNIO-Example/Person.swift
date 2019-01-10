//
//  Person.swift
//  ZenNIO-Example
//
//  Created by admin on 29/12/2018.
//

import Foundation

struct Person: Codable {
    var id: UUID
    var firstName: String
    var lastName: String
    var email: String?
}
