//
//  GameErrorTests.swift
//  SI_GameEngine
//
//  Created by Amarjit on 15/10/2025.
//

import XCTest
@testable import SI_GameEngine

/*
final class GameErrorTests: XCTestCase {
    func testInvalidActionNotReady() {
        let model = GameModel(coins: 100, score: 50, isReady: false)
        
        XCTAssertThrowsError(try model.performAction("attack")) { error in
            guard let gameError = error as? GameError else {
                XCTFail("Unexpected error type: \(error)")
                return
            }
            print("💡 Caught expected error: \(gameError.description)")
            XCTAssertEqual(gameError.domain, "Gameplay")
        }
    }
    
    func testNotEnoughCoins() {
        let model = GameModel(coins: 3, score: 10, isReady: true)
        
        XCTAssertThrowsError(try model.performAction("buyItem")) { error in
            if let gameError = error as? GameError {
                XCTAssertEqual(gameError.domain, "Resource")
                print("✔️ \(gameError.errorDescription)")
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }
}
*/
