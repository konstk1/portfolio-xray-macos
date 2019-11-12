//
//  Fund.swift
//  portfolio-xray-macos
//
//  Created by Konstantin Klitenik on 10/27/19.
//  Copyright © 2019 KK. All rights reserved.
//

import Foundation

struct Fund: Identifiable {
    let id = UUID()

    var ticker: String {
        didSet {
            equityUs = -1
            equityForeign = -1
            fixedIncome = -1
            equitySmall = -1
            equityMedium = -1
            equityLarge = -1
            equityForeignEstablished = -1
            equityForeignEmerging = -1
            fee = -1
            trailing3YearTaxCostRatio = -1
        }
    }
    
    var equityUs: Percent = -1
    var equityForeign: Percent = -1
    var fixedIncome: Percent = -1
    
    var equitySmall: Percent = -1
    var equityMedium: Percent = -1
    var equityLarge: Percent = -1
    var equityForeignEstablished: Percent = -1
    var equityForeignEmerging: Percent = -1
    
    var fee: Percent = -1
    var trailing3YearTaxCostRatio: Percent = -1
    
}
