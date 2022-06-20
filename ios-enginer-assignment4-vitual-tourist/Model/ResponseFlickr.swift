//
//  ResponseFlickr.swift
//  ios-enginer-assignment4-vitual-tourist
//
//  Created by Yu Zhao on 20.06.22.
//

import Foundation

struct ResponseFlickr: Codable {
    let photos: Photos
    let stat: String?
}

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Images]
}

struct Images: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}
