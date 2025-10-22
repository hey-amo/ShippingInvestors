//
//  PlayerViewModel.swift
//  Shipping-Investors
//
//  Created by Amarjit on 22/10/2025.
//

import Foundation

struct PlayerViewModel: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
    let coins: Int
}
