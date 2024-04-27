//
//  Result.swift
//  ShoppingProject
//
//  Created by Furkan Bayır on 14.04.2024.
//

import Foundation

struct ServiceResponse: Codable {
    let result: Result?
}

struct Result: Codable {
    let code, message, userid: String?
    let name, photo: String?
    let exist: String?
}
