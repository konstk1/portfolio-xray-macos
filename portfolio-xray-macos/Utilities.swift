//
//  Utilities.swift
//  portfolio-xray-macos
//
//  Created by Konstantin Klitenik on 10/26/19.
//  Copyright © 2019 KK. All rights reserved.
//

import Foundation

extension URLRequest {
    init(endpoint: String, query: [String: String], headers: [String: String]) {
        var components = URLComponents(string: endpoint)!
        components.queryItems = query.map { URLQueryItem(name: $0, value: $1) }
        
        self.init(url: components.url!)
        self.allHTTPHeaderFields = headers
    }
}
