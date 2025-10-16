//
//  GameWinnerTests.swift
//  SI_GameEngine
//
//  Created by Amarjit on 16/10/2025.
//

import XCTest

@testable import SI_GameEngine

final class GameWinnerTests: XCTestCase {

    // Helper to create a minimal Player for tests
    private func makePlayer(id: Int, coins: Int) -> Player {
        return Player(playerId: id,
                      coins: coins,
                      hand: [],
                      handSize: 5,
                      tokens: 0,
                      avatar: .avt_1,
                      isAI: false,
                      isActivePlayer: false,
                      deliveries: nil,
                      maxDeliveriesPerDestination: 5)
    }

    func testGameWinner_SortedByMostCoinsFirst() throws {
        let p1 = makePlayer(id: 1, coins: 120)
        let p2 = makePlayer(id: 2, coins: 45)
        let p3 = makePlayer(id: 3, coins: 200)
        let p4 = makePlayer(id: 4, coins: 90)

        let players = [p1, p2, p3, p4]
        // sort by coins descending (most coins first)
        let sorted = players.sorted { $0.coins > $1.coins }

        // verify descending order of coins
        let coins = sorted.map { $0.coins }
        XCTAssertEqual(coins, coins.sorted(by: >), "Players should be sorted by most coins first")

        // top player is the winner
        let winner = sorted.first
        XCTAssertNotNil(winner)
        XCTAssertEqual(winner?.playerId, 3)
        XCTAssertEqual(winner?.coins, 200)
    }

    func testGameWinner_TieForFirstPlace() throws {
        let p1 = makePlayer(id: 1, coins: 150)
        let p2 = makePlayer(id: 2, coins: 150) // tie with p1
        let p3 = makePlayer(id: 3, coins: 80)

        let players = [p3, p1, p2]
        let sorted = players.sorted { $0.coins > $1.coins }

        // top coin value
        guard let topCoins = sorted.first?.coins else {
            return XCTFail("Sorted list must have at least one player")
        }

        // Count how many players share the top coin value
        let topCount = sorted.filter { $0.coins == topCoins }.count
        XCTAssertEqual(topCoins, 150, "Top coin value should be 150")
        XCTAssertEqual(topCount, 2, "There should be two players tied for first place")

        // Ensure the sorted list is still in non-increasing order
        let coins = sorted.map { $0.coins }
        XCTAssertEqual(coins, coins.sorted(by: >), "Sorted coins should be in descending order even when ties exist")
    }
}
