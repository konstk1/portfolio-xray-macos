//
//  MorningStar+Types.swift
//  portfolio-xray-macos
//
//  Created by Konstantin Klitenik on 10/26/19.
//  Copyright © 2019 KK. All rights reserved.
//

import Foundation

extension MorningStar {
    struct EntitySearchResponse: Decodable {
        let count: Int
        let pages: Int
        let results: [EntityResult]
    }
    
    struct EntityResult: Decodable {
        let id: String
        let exchange: String
        let securityType: String
        let ticker: String
        let name: String
        let performanceId: String
    }
    
    struct Security: Decodable {
        let name: String
        let exchange: String
        let performanceId: String
        let secId: String
        let ticker: String
        let type: String
    }
}
