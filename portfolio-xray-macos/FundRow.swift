//
//  FundRow.swift
//  portfolio-xray-macos
//
//  Created by Konstantin Klitenik on 11/7/19.
//  Copyright © 2019 KK. All rights reserved.
//

import SwiftUI

struct PercentField: View {
    var value: Percent
    var width: CGFloat = 65
    
    var body: some View {
        Text(String(format: "\(value < 0 ? "--" : "%9.2f%%")", value))
            .frame(width: width, alignment: .trailing)
    }
}

struct FundRow: View {
    @EnvironmentObject var portfolio: Portfolio
    let fund: Fund
    var idx: Int { portfolio.funds.firstIndex { $0.id == fund.id }! }
    
    let dataColumnWidth: CGFloat = 65
        
    var body: some View {
        HStack {
            TextField("Ticker", text: $portfolio.funds[idx].ticker, onCommit: {
                print("Editted \(self.portfolio.funds[self.idx].ticker)")
                let ticker = self.portfolio.funds[self.idx].ticker
                guard !ticker.isEmpty else { return }
                
                self.portfolio.fetchFundInfo(idx: self.idx)
            }).frame(width: dataColumnWidth, alignment: .leading)

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
    }
}

struct FundRow_Previews: PreviewProvider {
    static var previews: some View {
        let portfolio = Portfolio(persist: false)
        portfolio.addFund(ticker: "VFIAX")
        return FundRow(fund: portfolio.funds[0]).environmentObject(portfolio)
    }
}
