//
//  TurnOrderTests.swift
//  SI_GameEngine
//
//  Created by Amarjit on 16/10/2025.
//

import XCTest
@testable import SI_GameEngine

fileprivate struct TestPlayer: TurnTaking {
    let playerId: Int
}

final class TurnOrderManagerTests: XCTestCase {
    
    func testInitialActivePlayer_IsLowestPlayerId() {
        let players = [TestPlayer(playerId: 3), TestPlayer(playerId: 1), TestPlayer(playerId: 2)]
        let manager = TurnOrderManager(players: players)
        
        // players should be sorted by playerId
        let sortedIds = manager.players.map { $0.playerId }
        XCTAssertEqual(sortedIds, [1, 2, 3], "Players should be sorted by playerId on init")
        
        // active player should be the lowest id (first in sorted list)
        XCTAssertEqual(manager.activePlayer.playerId, 1, "Initial active player should be the lowest playerId")
    }
    
    func testNextTurn_CyclesThroughPlayers() {
        let players = [TestPlayer(playerId: 3), TestPlayer(playerId: 1), TestPlayer(playerId: 2)]
        let manager = TurnOrderManager(players: players)
        
        XCTAssertEqual(manager.activePlayer.playerId, 1)
        manager.nextTurn()
        XCTAssertEqual(manager.activePlayer.playerId, 2)
        manager.nextTurn()
        XCTAssertEqual(manager.activePlayer.playerId, 3)
        manager.nextTurn()
        // wraps around
        XCTAssertEqual(manager.activePlayer.playerId, 1)
    }
    
    func testSinglePlayer_NextTurnNoChange() {
        let players = [TestPlayer(playerId: 5)]
        let manager = TurnOrderManager(players: players)
        
        XCTAssertEqual(manager.activePlayer.playerId, 5)
        manager.nextTurn()
        XCTAssertEqual(manager.activePlayer.playerId, 5)
        manager.nextTurn()
        XCTAssertEqual(manager.activePlayer.playerId, 5)
    }
}
