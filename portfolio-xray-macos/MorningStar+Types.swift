//
//  MorningStar+Types.swift
//  portfolio-xray-macos
//
//  Created by Konstantin Klitenik on 10/26/19.
//  Copyright © 2019 KK. All rights reserved.
//

import Foundation

extension MorningStar {
    enum Endpoint: String {
        case entitySearch = "https://www.morningstar.com/api/v1//search/entities"
        case securitySearch = "https://www.morningstar.com/api/v1/securities/search"
        case fundAssets  = "https://api-global.morningstar.com/sal-service/v1/fund/process/asset/[fundId]/data"
        case fundCapInfo = "https://api-global.morningstar.com/sal-service/v1/fund/process/marketCap/[fundId]/data"
        case fundRegions = "https://api-global.morningstar.com/sal-service/v1/fund/portfolio/regionalSector/[fundId]/data"
        case fundFee     = "https://api-global.morningstar.com/sal-service/v1/fund/price/feeLevel/[fundId]/data"
        case fundTaxes   = "https://api-global.morningstar.com/sal-service/v1/fund/price/taxes/[fundId]/data"
    }
    
    var searchHeaders: [String: String] {[
      "accept-encoding": "gzip, deflate, br",
      "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36",
      "accept": "application/json, text/plain, */*",
      "x-api-key": searchApiKey,
    ]}
    
    var dataHeaders: [String: String] {[
        "accept-encoding": "gzip, deflate, br",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36",
        "Accept": "application/json, text/plain, */*",
        "ApiKey": dataApiKey,
    ]}
    
    struct EntitySearchResponse: Decodable {
        let count: Int
        let pages: Int
        let results: [Entity]
    }
    
    struct Entity: Decodable {
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
    
    struct AssetsResult: Decodable {
        let assetType: String
        let allocationMap: AllocationMap
        let categoryName: String
        let countryCode: String
        let fundName: String
        let indexName: String
        let portfolioDate: String       // date of this data
    }
    
    struct AllocationMap: Decodable {
        let AssetAllocCash: Allocation
        let AssetAllocNonUSEquity: Allocation
        let AssetAllocBond: Allocation
        let AssetAllocNotClassified: Allocation
        let AssetAllocOther: Allocation
        let AssetAllocUSEquity: Allocation
    }
    
    struct Allocation: Decodable {
        let netAllocation: String
    }
    
    struct MarketCapResult: Decodable {
        let assetType: String
        let currencyId: String
        let fund: FundCapAlloc
        let portfolioDate: String
    }
    
    struct FundCapAlloc: Decodable {
        let avgMarketCap: Double
        let giant: Double
        let large: Double
        let medium: Double
        let small: Double
        let micro: Double
    }
    
    struct RegionAlloc: Decodable {
        let assetType: String
        let fundName: String
        let fundPortfolio: Regions
        
    }
    
    struct Regions: Decodable {
        let africaMiddleEast: Double
        let asiaDeveloped: Double
        let asiaEmerging: Double
        let australasia: Double
        let europeDeveloped: Double
        let europeEmerging: Double
        let japan: Double
        let latinAmerica: Double
        let northAmerica: Double
        let unitedKingdom: Double
    }
    
    struct Fees: Decodable {
        var fundFee: Percent
    }
    
    struct Taxes: Decodable {
        var trailing3YearTaxCostRatio: Percent
    }
    
    enum MorningStarError: Error {
        case invalidRequest
        case entityNotFound
        case otherError
    }
}
