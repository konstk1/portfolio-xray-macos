//
//  Portfolio.swift
//  portfolio-xray-macos
//
//  Created by Konstantin Klitenik on 10/27/19.
//  Copyright © 2019 KK. All rights reserved.
//

import Foundation
import Combine

final class Portfolio: ObservableObject {
    @Published var funds: [Fund] = []
    
    private var shouldPersist: Bool = false
    
    private let morningStar = MorningStar()
    
    private var subs: Set<AnyCancellable> = []
    
    init(persist: Bool) {
        shouldPersist = persist
        
        if shouldPersist {
            if let tickers = UserDefaults.standard.stringArray(forKey: "tickers") {
                print("Loading tickers [\(tickers)]")
                addFunds(tickers: tickers)
            }
            
            $funds.debounce(for: 1.0, scheduler: DispatchQueue.global()).sink { [weak self] _funds in
                self?.saveFunds()
            }.store(in: &subs)
        }
    }
    
    func saveFunds() {
        guard shouldPersist else { return }
        
        let tickers = funds.map { $0.ticker }
        UserDefaults.standard.set(tickers, forKey: "tickers")
        print("Saving tickers [\(tickers)]")
    }
    
    func addFund(ticker: String) {
        funds.append(Fund(ticker: ticker))
        if !ticker.isEmpty {
            fetchFundInfo(idx: funds.count - 1)
        }
    }
    
    func addFunds(tickers: [String]) {
        funds.append(contentsOf: tickers.map { Fund(ticker: $0) })
        funds.enumerated().forEach { index, _ in
            fetchFundInfo(idx: index)
        }
    }
    
    func remove(fund: Fund) {
        funds.removeAll { $0.id == fund.id }
    }
    
    func fetchFundInfo(idx: Int) {
        let ticker = funds[idx].ticker
        
        morningStar.findSecurities(prefix: ticker, limit: 1).sink(receiveCompletion: { error in
            print("Status: \(error) \(ticker)")
        }) { [weak self] securities in
            guard let self = self else { return }
            
            // ensure first result is exact match (case-insensitive)
            guard let security = securities.first,
                security.ticker.lowercased() == ticker.lowercased() else { return }
            
            DispatchQueue.main.async {
                self.funds[idx].ticker = security.ticker
                self.funds[idx].name = security.name
            }
            
            self.morningStar.getAssetAllocation(for: security).receive(on: RunLoop.main).sink(receiveCompletion: { _ in }) { [weak self] assets in
//                print("Got assets")
                self?.funds[idx].equityUs = Percent(assets.AssetAllocUSEquity.netAllocation) ?? -1
                self?.funds[idx].equityForeign = Percent(assets.AssetAllocNonUSEquity.netAllocation) ?? -1
                self?.funds[idx].fixedIncome = Percent(assets.AssetAllocBond.netAllocation) ?? -1 
            }.store(in: &self.subs)
            
            self.morningStar.getCapAllocation(for: security).receive(on: RunLoop.main).sink(receiveCompletion: { _ in }) { [weak self] alloc in
//                print("Got alloc")
                self?.funds[idx].equityLarge = alloc.giant + alloc.large
                self?.funds[idx].equityMedium = alloc.medium
                self?.funds[idx].equitySmall = alloc.small + alloc.micro
            }.store(in: &self.subs)
            
            self.morningStar.getRegionAlloc(for: security).receive(on: RunLoop.main).sink(receiveCompletion: { _ in }) { [weak self] regions in
//                print("Got regions")
                self?.funds[idx].equityForeignEmerging = regions.asiaEmerging + regions.europeEmerging + regions.africaMiddleEast
                self?.funds[idx].equityForeignEstablished = regions.europeDeveloped + regions.asiaDeveloped + regions.australasia + regions.japan + regions.latinAmerica
            }.store(in: &self.subs)
            
            self.morningStar.getFees(for: security).receive(on: RunLoop.main).sink(receiveCompletion: { _ in }) { [weak self] fees in
//                print("Got fees")
                self?.funds[idx].fee = fees.fundFee
            }.store(in: &self.subs)
            
            self.morningStar.getTaxes(for: security).receive(on: RunLoop.main).sink(receiveCompletion: { _ in }) { [weak self] taxes in
//                print("Got taxes")
                self?.funds[idx].trailing3YearTaxCostRatio = taxes.trailing3YearTaxCostRatio
            }.store(in: &self.subs)
            
        }.store(in: &subs)
        
        print("Fetching subs \(subs.count)")
    }
}
