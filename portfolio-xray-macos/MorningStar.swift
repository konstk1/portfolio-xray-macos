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
    
    func getAllocation(for ticker: String) -> AnyPublisher<AllocationMap, Error> {
        return findEntity(ticker: ticker)
            .flatMap { self.findSecurity(for: $0) }
            .flatMap { self.getAssetAllocation(for: $0) }
            .eraseToAnyPublisher()
    }
    
    func findEntity(ticker: String) -> AnyPublisher<Entity, Error> {
        print("Finding entity for \(ticker)")
        let query = [
            "q": ticker,
            "limit": "1",
            "autocomplete": "false"
        ]
    
        let request = URLRequest(endpoint: Endpoint.entitySearch.rawValue, query: query, headers: searchHeaders)

        return urlSession.dataTaskPublisher(for: request)
            .map { print(String(data: $0.data, encoding: .utf8)); return $0.data }
            .decode(type: EntitySearchResponse.self, decoder: JSONDecoder())
            .tryMap {
                guard let result = $0.results.first else { throw MorningStarError.entityNotFound }
                return result
            }
            .eraseToAnyPublisher()
    }
    
    func findSecurity(for entity: Entity) -> AnyPublisher<Security, Error> {
        print("Finding security for \(entity.ticker)")
        let query = [
            "type": entity.securityType,
            "exchange": entity.exchange,
            "ticker": entity.ticker,
        ]
        
        let request = URLRequest(endpoint: Endpoint.securitySearch.rawValue, query: query, headers: searchHeaders)
        
        return urlSession.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [Security].self, decoder: JSONDecoder())
            .tryMap {
                guard let security = $0.first else { throw MorningStarError.entityNotFound }
                return security
            }
            .eraseToAnyPublisher()
    }
    
    func findSecurity(ticker: String) -> AnyPublisher<Security, Error> {
        return findEntity(ticker: ticker).flatMap { [unowned self] in
                self.findSecurity(for: $0)
            }.eraseToAnyPublisher()
    }
    
    func getAssetAllocation(for security: Security) -> AnyPublisher<AllocationMap, Error> {
        let url = Endpoint.fundAssets.rawValue.replacingOccurrences(of: "[fundId]", with: security.secId)
        
        let request = URLRequest(endpoint: url, query: [:], headers: dataHeaders)
        
        return urlSession.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: AssetsResult.self, decoder: JSONDecoder())
            .map { $0.allocationMap }
            .eraseToAnyPublisher()
    }
    
    func getCapAllocation(for security: Security) -> AnyPublisher<FundCapAlloc, Error> {
        print("Getting cap alloc for \(security.ticker)")
        let url = Endpoint.fundCapInfo.rawValue.replacingOccurrences(of: "[fundId]", with: security.secId)
        
        let request = URLRequest(endpoint: url, query: [:], headers: dataHeaders)
        
        return urlSession.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: MarketCapResult.self, decoder: JSONDecoder())
            .map { $0.fund }
            .eraseToAnyPublisher()
    }
    
    func getRegionAlloc(for security: Security) -> AnyPublisher<Regions, Error> {
        let url = Endpoint.fundRegions.rawValue.replacingOccurrences(of: "[fundId]", with: security.secId)
        
        let request = URLRequest(endpoint: url, query: [:], headers: dataHeaders)
        
        return urlSession.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: RegionAlloc.self, decoder: JSONDecoder())
            .map { $0.fundPortfolio }
            .eraseToAnyPublisher()
    }
    
    func getFees(for security: Security) -> AnyPublisher<Fees, Error> {
        let url = Endpoint.fundFee.rawValue.replacingOccurrences(of: "[fundId]", with: security.secId)
        
        let request = URLRequest(endpoint: url, query: [:], headers: dataHeaders)
        
        return urlSession.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Fees.self, decoder: JSONDecoder())
//            .map { $0.fundPortfolio }
            .eraseToAnyPublisher()
    }
    
    func getTaxes(for security: Security) -> AnyPublisher<Taxes, Error> {
        let url = Endpoint.fundTaxes.rawValue.replacingOccurrences(of: "[fundId]", with: security.secId)
        
        let request = URLRequest(endpoint: url, query: [:], headers: dataHeaders)
        
        return urlSession.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Taxes.self, decoder: JSONDecoder())
//            .map { $0.fundPortfolio }
            .eraseToAnyPublisher()
    }
}


