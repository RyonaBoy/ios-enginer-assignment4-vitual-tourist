//
//  RequestFlickr.swift
//  ios-enginer-assignment4-vitual-tourist
//
//  Created by Yu Zhao on 20.06.22.
//

import Foundation

struct RequestFlickr: Codable {
    let api_key: String
    let lat: Double
    let lon: Double
}
