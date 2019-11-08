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
    @ObservedObject private var portfolio: Portfolio = Portfolio()
    @State private var cancelable: AnyCancellable?
            
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Ticker                 ")
                Text("US L       ")
                Text("US M       ")
                Text("US S     ")
                Text("Fgn Est ")
                Text("Fgn Emr   ")
            }
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
            .onAppear() {
            self.portfolio.addFund(ticker: "VFIAX")
        }
    }
}


struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
    }
}
