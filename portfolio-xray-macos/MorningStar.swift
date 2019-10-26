//
//  MorningStar.swift
//  portfolio-xray-macos
//
//  Created by Konstantin Klitenik on 10/26/19.
//  Copyright © 2019 KK. All rights reserved.
//

import Foundation
import Combine

final class MorningStar {
    let urlSession = URLSession.shared
    
    let searchApiKey = "Nrc2ElgzRkaTE43D5vA7mrWj2WpSBR35fvmaqfte"
    let dataApiKey = "lstzFDEOhfFNMLikKa0am9mgEKLBl49T"
    
    enum Endpoint: String {
        case search = "https://www.morningstar.com/api/v1//search/entities"
        case fundIdSearch = "https://www.morningstar.com/api/v1/securities/search?type='+sec.type+'&exchange='+sec.exchange+'&ticker='+sec.ticker"
        case fundAssets = "https://api-global.morningstar.com/sal-service/v1/fund/process/asset/'+fundId+'/data?locale=en"
        case fundCapInfo = "https://api-global.morningstar.com/sal-service/v1/fund/process/marketCap/'+fundId+'/data?clientId=MDC"
        
    }
    
    lazy var searchHeaders = {[
      "accept-encoding": "gzip, deflate, br",
      "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36",
      "accept": "application/json, text/plain, */*",
      "x-api-key": searchApiKey,
    ]}()
    
    lazy var dataHeaders = {[
        "accept-encoding": "gzip, deflate, br",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36",
        "Accept": "application/json, text/plain, */*",
        "ApiKey": dataApiKey,
    ]}()
    
    func getAllocation(for ticker: String) -> String {
        let fundId = getFundId(for: ticker)
        return getAssetAllocation(for: fundId)
        
    }
    
    func getFundId(for ticker: String) -> String {
        let sec = findEntity(ticker: ticker)
//        return findFundId(for: sec)
        return ""
    }
    
    func findEntity(ticker: String) -> AnyPublisher<EntityResult?, Error> {
        let query = [
            "q": ticker,
            "limit": "1",
            "autocomplete": "false"
        ]
    
        var request = URLRequest(endpoint: Endpoint.search.rawValue, query: query, headers: searchHeaders)

        return urlSession.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: EntitySearchResponse.self, decoder: JSONDecoder())
            .tryMap { $0.results.first }
            .eraseToAnyPublisher()
    }
    
    func findSecurity(for entity: EntityResult) -> AnyPublisher<Security?, Error> {
        let query = [
            "type": entity.securityType,
            "exchange": entity.exchange,
            "ticker": entity.ticker,
        ]
        
        let request = URLRequest(endpoint: Endpoint.fundIdSearch.rawValue, query: query, headers: searchHeaders)
        
        return urlSession.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [Security].self, decoder: JSONDecoder())
            .tryMap { $0.first }
            .eraseToAnyPublisher()
    }
    
    func getAssetAllocation(for fundId: String) -> String {
        
        
//        var url = 'https://api-global.morningstar.com/sal-service/v1/fund/process/asset/'+fundId+'/data?locale=en';
//
//        var response = UrlFetchApp.fetch(url, options);
//        var json = JSON.parse(response.getContentText());
//        var map = json.allocationMap;
//
//        var allocation = {
//          bonds: parseFloat(map.AssetAllocBond.netAllocation) / 100.0,
//          cash: parseFloat(map.AssetAllocCash.netAllocation) / 100.0,
//          usEquity: parseFloat(map.AssetAllocUSEquity.netAllocation) / 100.0,
//          intlEquity: parseFloat(map.AssetAllocNonUSEquity.netAllocation) / 100.0,
//          notClassified: parseFloat(map.AssetAllocNotClassified.netAllocation) / 100.0,
//          other: parseFloat(map.AssetAllocOther.netAllocation) / 100.0,
//        };
//
//        return allocation;
        return ""
    }
    
    func getCapAllocation(for fundId: String) -> String {
//        var url = 'https://api-global.morningstar.com/sal-service/v1/fund/process/marketCap/'+fundId+'/data?clientId=MDC';
//        const options = {
//          headers: {
//            'accept-encoding': 'gzip, deflate, br',
//            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36',
//            'Accept': 'application/json, text/plain, */*',
//            'ApiKey': dataApiKey,
//          },
//        };
//
//        var response = UrlFetchApp.fetch(url, options);
//        var json = JSON.parse(response.getContentText());
//        var fund = json.fund;
//
//        Logger.log(equity);
//
//        var equity = {
//          large: fund.giant + fund.large,
//          medium: fund.medium,
//          small: fund.small + fund.micro,
//        }
//
//        Logger.log(equity);
//        return equity;
        return ""
    }
}


