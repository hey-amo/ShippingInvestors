//
//  CommonErrorTests.swift
//  SI_GameEngine
//
//  Created by Amarjit on 15/10/2025.
//

import XCTest
@testable import SI_GameEngine

fileprivate func purchase(coins: Int, cost: Int) throws {
    guard coins >= cost else {
        throw CommonError.notEnoughCoins(required: cost, available: coins)
    }
}


final class CommonErrorTests: XCTestCase {
    func testNotEnoughCoins() throws {
        let coins = 3
        let cost = 10
                
        XCTAssertThrowsError(try purchase(coins: coins, cost: cost)) { error in
            if let cError = error as? CommonError {
                XCTAssertEqual(cError.domain, "Funds")
                print("✔️ \(cError.localizedDescription)")
            } else {
                XCTFail("Unexpected error type: \(error.localizedDescription)")
            }
        }
    }
}

/*
XCTAssertThrowsError(try model.performAction("attack")) { error in
    guard let gameError = error as? GameError else {
        XCTFail("Unexpected error type: \(error)")
        return
    }
    print("💡 Caught expected error: \(gameError.description)")
    XCTAssertEqual(gameError.domain, "Gameplay")
}
*/
