//
//  ContentView.swift
//  portfolio-xray-macos
//
//  Created by Konstantin Klitenik on 10/26/19.
//  Copyright © 2019 KK. All rights reserved.
//

import SwiftUI
import Combine

struct PortfolioView: View {
    @EnvironmentObject private var portfolio: Portfolio
    @State private var cancelable: AnyCancellable?
            
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Group {
                    Text("Ticker").frame(width: 65)
                    Text("US").frame(width: 65, alignment: .trailing)
                    Text("Foreign").frame(width: 65, alignment: .trailing)
                    Text("Fixed").frame(width: 65, alignment: .trailing)
                }
                Divider()
                Text("Large").frame(width: 65, alignment: .trailing)
                Text("Medium").frame(width: 65, alignment: .trailing)
                Text("Small").frame(width: 65, alignment: .trailing)
                Divider()
                Text("Fgn Est").frame(width: 65, alignment: .trailing)
                Text("Fgn Emr").frame(width: 65, alignment: .trailing)
            }.fixedSize()
            VStack(alignment: .leading) {
                ForEach(self.portfolio.funds) { fund in
                    FundRow(fund: fund).environmentObject(self.portfolio)
                }
            }
            Button("Add fund") {
                print("Add fund")
                self.portfolio.addFund(ticker: "")
            }
        }
            .padding()
//            .onAppear() {
//            self.portfolio.addFund(ticker: "VFIAX")
//            self.portfolio.addFund(ticker: "VTIAX")
//        }
    }
}


struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        let portfolio = Portfolio(persist: false)
        portfolio.addFund(ticker: "VFIAX")
        portfolio.addFund(ticker: "VTIAX")
        
        return PortfolioView()
            .frame(width: 700, height: 150)
            .environmentObject(portfolio)   
    }
}
