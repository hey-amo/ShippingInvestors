//
//  ContentView.swift
//  Shipping-Investors
//
//  Created by Amarjit on 20/10/2025.
//

import SwiftUI
import SI_GameEngine
import SwiftData

struct MainMenuView: View {
    var body: some View {
        VStack {
            Text("Shipping Investors")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            Button("Start Game") {
            }
            .buttonStyle(.borderedProminent)
            
            Button("Continue Game") {
                
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
    }

}

#Preview {
    MainMenuView()
}
