//
//  GameModelTests.swift
//  SI_GameEngine
//
//  Created by Amarjit on 14/10/2025.
//

import XCTest
@testable import SI_GameEngine

final class GameModelTests: XCTestCase {

    var gameModel: GameModel?
    
    override func setUpWithError() throws {
        // Setup
        let players: [Player] = [
            Player(playerId: 1, coins: 5, handSize: 3, tokens: 6, avatar: .avt_1, isAI: false, isActivePlayer: false, maxDeliveriesPerDestination: 5),
            Player(playerId: 2, coins: 5, handSize: 3, tokens: 6, avatar: .avt_2, isAI: false, isActivePlayer: false, maxDeliveriesPerDestination: 5),
            Player(playerId: 3, coins: 5, handSize: 3, tokens: 6, avatar: .avt_3, isAI: false, isActivePlayer: false, maxDeliveriesPerDestination: 5),
        ]
        self.gameModel = GameSetupManager().setup(for: players)
    }

    override func tearDownWithError() throws {
        // Teardown
        self.gameModel = nil
    }
    
}
