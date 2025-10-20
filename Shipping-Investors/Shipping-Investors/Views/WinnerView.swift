//
//  WinnerView.swift
//  Shipping-Investors
//
//  Created by Amarjit on 20/10/2025.
//

import SwiftUI

struct PlayerResult: Identifiable {
    let id = UUID()
    let name: String
    let coins: Int
}

struct WinnerScreenView: View {
    // Dummy data
    let players: [PlayerResult] = [
        PlayerResult(name: "Alice", coins: 18),
        PlayerResult(name: "Bob", coins: 30),
        PlayerResult(name: "Charlie", coins: 22),
        PlayerResult(name: "Diana", coins: 15)
    ]
    
    var sortedPlayers: [PlayerResult] {
        players.sorted { $0.coins > $1.coins }
    }
    
    var winners: [PlayerResult] {
        let maxCoins = sortedPlayers.first?.coins ?? 0
        return sortedPlayers.filter { $0.coins == maxCoins }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 24)
                Image(systemName: "trophy.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.yellow)
                
                Text(winners.count == 1 ? "\(winners.first!.name) is the Winner" : "It's a Tie!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if winners.count > 1 {
                    HStack(spacing: 12) {
                        ForEach(winners) { winner in
                            Text(winner.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .cornerRadius(8)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(sortedPlayers) { player in
                        HStack {
                            Text(player.name)
                                .font(.body)
                                .fontWeight(winners.contains(where: { $0.id == player.id }) ? .bold : .regular)
                            Spacer()
                            Text("$\(player.coins) ")
                                .font(.body)
                                .fontWeight(winners.contains(where: { $0.id == player.id }) ? .bold : .regular)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
                
                Spacer(minLength: 24)
                
                Button(action: {
                    print("Play button pressed")
                    // Hook for Play action
                }) {
                    Text("Play again")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.bottom, 24)
            }
            .frame(maxWidth: 400)
            .padding(.horizontal)
            .padding(.top, 16)
        }
        .background(Color(.systemTeal).opacity(0.10).ignoresSafeArea())
    }
}

#Preview {
    WinnerScreenView()
}
