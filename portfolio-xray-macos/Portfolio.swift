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
    @Published var funds: [Fund] = [] {
        didSet {
            let tickers = funds.map { $0.ticker }
            UserDefaults.standard.set(tickers, forKey: "tickers")
            print("Saving tickers [\(tickers)]")
        }
    }
    
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
        }
    }
    
    func addFund(ticker: String) {
        funds.append(Fund(ticker: ticker))
        if !ticker.isEmpty {
            fetchFundInfo(idx: funds.count - 1)
        }
    }
    
    func addFunds(tickers: [String]) {
        funds.append(contentsOf: tickers.map { Fund(ticker: $0) })
    }
    
    func fetchFundInfo(idx: Int) {
        let ticker = funds[idx].ticker
        
        morningStar.findSecurity(ticker: ticker).sink(receiveCompletion: { error in
            print(error)
        }) { [weak self] security in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.funds[idx].ticker = security.ticker
            }
            
            self.morningStar.getAssetAllocation(for: security).receive(on: RunLoop.main).sink(receiveCompletion: { _ in }) { [weak self] assets in
                print("Got assets")
                self?.funds[idx].equityUs = Percent(assets.AssetAllocUSEquity.netAllocation) ?? -1
                self?.funds[idx].equityForeign = Percent(assets.AssetAllocNonUSEquity.netAllocation) ?? -1
                self?.funds[idx].fixedIncome = Percent(assets.AssetAllocBond.netAllocation) ?? -1 
            }.store(in: &self.subs)
            
            self.morningStar.getCapAllocation(for: security).receive(on: RunLoop.main).sink(receiveCompletion: { _ in }) { [weak self] alloc in
                print("Got alloc")
                self?.funds[idx].equityLarge = alloc.giant + alloc.large
                self?.funds[idx].equityMedium = alloc.medium
                self?.funds[idx].equitySmall = alloc.small + alloc.micro
            }.store(in: &self.subs)
            
            self.morningStar.getRegionAlloc(for: security).receive(on: RunLoop.main).sink(receiveCompletion: { _ in }) { [weak self] regions in
                print("Got regions")
                self?.funds[idx].equityForeignEmerging = regions.asiaEmerging + regions.europeEmerging + regions.africaMiddleEast
                self?.funds[idx].equityForeignEstablished = regions.europeDeveloped + regions.asiaDeveloped + regions.australasia + regions.japan + regions.latinAmerica
            }.store(in: &self.subs)
        }.store(in: &subs)
    }
}
