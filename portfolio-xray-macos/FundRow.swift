//
//  FundRow.swift
//  portfolio-xray-macos
//
//  Created by Konstantin Klitenik on 11/7/19.
//  Copyright © 2019 KK. All rights reserved.
//

import SwiftUI
import Combine

struct PercentField: View {
    var value: Percent
    var width: CGFloat = 65
    
    var body: some View {
        Text(String(format: "\(value < 0 ? "--" : "%9.2f%%")", value))
            .frame(width: width, alignment: .trailing)
    }
}

class FundRowViewModel: ObservableObject {
    var ticker: String = "" {
        didSet {
            cancellable?.cancel()   // cancel previous request
            cancellable = morningStar.findSecurities(prefix: ticker).receive(on: RunLoop.main).sink(receiveCompletion: { _ in }) { [weak self] securities in
                self?.tickerSuggestions = securities.map { $0.ticker }.joined(separator: ", ")
            }
                
        }
    }
    
    @Published var tickerSuggestions: String = ""
    
    private var morningStar = MorningStar()
    private var cancellable: AnyCancellable?
    
    init(ticker: String) {
        self.ticker = ticker
    }
}

struct FundRow: View {
    @EnvironmentObject var portfolio: Portfolio
    let fund: Fund
    @State private var hoveringInside = false
    
    @ObservedObject private var fundRowModel: FundRowViewModel
    
    private var idx: Int { portfolio.funds.firstIndex { $0.id == fund.id }! }
    
    init(fund: Fund) {
        self.fund = fund
        fundRowModel = FundRowViewModel(ticker: fund.ticker)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if (!fundRowModel.tickerSuggestions.isEmpty) {
                Text(fundRowModel.tickerSuggestions)
            }
            HStack {
                TextField("Ticker", text: $fundRowModel.ticker, onCommit: {
                    let ticker = self.fundRowModel.ticker
                    guard ticker != self.portfolio.funds[self.idx].ticker else { return }
                    
                    print("Updated ticker '\(ticker)'")
                    self.portfolio.funds[self.idx].ticker = ticker
                    
                    if !ticker.isEmpty {
                        self.portfolio.fetchFundInfo(idx: self.idx)
                    }
                }).frame(width: 65, alignment: .leading)

                Group {
                    PercentField(value: fund.equityUs)
                    PercentField(value: fund.equityForeign)
                    PercentField(value: fund.fixedIncome)
                }
                Divider()
                Group {
                    PercentField(value: fund.equityLarge)
                    PercentField(value: fund.equityMedium)
                    PercentField(value: fund.equitySmall)
                }
                Divider()
                Group {
                    PercentField(value: fund.equityForeignEstablished)
                    PercentField(value: fund.equityForeignEmerging)
                }
                Divider()
                Group {
                    PercentField(value: fund.fee)
                    PercentField(value: fund.trailing3YearTaxCostRatio)
                }
            }.fixedSize()
//            .onHover { inside in
//                self.hoveringInside = inside
//            }
//
//            if (hoveringInside) {
//                Text(portfolio.funds[idx].name).padding(.horizontal, 4).background(Color.white)
//            }
        } // end ZStack
    }
}

struct FundRow_Previews: PreviewProvider {
    static var previews: some View {
        let portfolio = Portfolio(persist: false)
        portfolio.addFund(ticker: "VFIAX")
        return FundRow(fund: portfolio.funds[0]).environmentObject(portfolio)
    }
}
