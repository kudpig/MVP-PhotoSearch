//
//  PhotoModel.swift
//  MVP-PhotoSearch
//
//  Created by Shinichiro Kudo on 2021/06/23.
//

import Foundation

struct PhotoAPIResponse: Codable {
    let results: [PhotoModel]?
}

struct PhotoModel: Codable {
    let id: String
    let urls: URLS
}

struct URLS: Codable {
    let regular: String
}
