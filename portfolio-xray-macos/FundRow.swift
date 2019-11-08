//
//  FundRow.swift
//  portfolio-xray-macos
//
//  Created by Konstantin Klitenik on 11/7/19.
//  Copyright © 2019 KK. All rights reserved.
//

import SwiftUI

struct FundRow: View {
    @EnvironmentObject var portfolio: Portfolio
    let fund: Fund
    var idx: Int { portfolio.funds.firstIndex { $0.id == fund.id }! }
    
    let dataColumnWidth: CGFloat = 65
        
    var body: some View {
        HStack {
            TextField("Ticker", text: $portfolio.funds[idx].ticker, onCommit: {
                print("Editted \(self.portfolio.funds[self.idx].ticker)")
                if !self.portfolio.funds[self.idx].ticker.isEmpty {
                    self.portfolio.fetchFundInfo(idx: self.idx)
                }
            }).frame(width: 65, alignment: .leading)

            Group {
                Text(String(format: "%9.2f%%", fund.equityUs)).frame(width: dataColumnWidth, alignment: .trailing)
                Text(String(format: "%9.2f%%", fund.equityForeign)).frame(width: dataColumnWidth, alignment: .trailing)
                Text(String(format: "%9.2f%%", fund.fixedIncome)).frame(width: dataColumnWidth, alignment: .trailing)
            }
            Divider()
            Text(String(format: "%9.2f%%", fund.equityLarge)).frame(width: dataColumnWidth, alignment: .trailing)
            Text(String(format: "%9.2f%%", fund.equityMedium)).frame(width: dataColumnWidth, alignment: .trailing)
            Text(String(format: "%9.2f%%", fund.equitySmall)).frame(width: dataColumnWidth, alignment: .trailing)
            Divider()
            Text(String(format: "%9.2f%%", fund.equityForeignEstablished)).frame(width: dataColumnWidth, alignment: .trailing)
            Text(String(format: "%9.2f%%", fund.equityForeignEmerging)).frame(width: dataColumnWidth, alignment: .trailing)
        }.fixedSize()
    }
}

struct FundRow_Previews: PreviewProvider {
    static var previews: some View {
        FundRow(fund: Fund(ticker: "VFIAX"))
    }
}
