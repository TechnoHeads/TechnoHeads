//
//  Bundle.swift
//  ShoppingProject
//
//  Created by Furkan Bayır on 14.04.2024.
//

import Foundation
import UIKit

extension Bundle {
    var apiBaseURL: String {
        return object(forInfoDictionaryKey: "serverBaseURL") as? String ?? ""
    }
}
