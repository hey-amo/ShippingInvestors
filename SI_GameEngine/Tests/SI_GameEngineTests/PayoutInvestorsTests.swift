//
//  PayoutInvestorsTests.swift
//  SI_GameEngine
//
//  Created by Amarjit on 16/10/2025.
//

import XCTest

@testable import SI_GameEngine

extension Dock {
    public func addInvestor(player: Player) throws {
        // each ship can only have 3 investors
        guard (self.investors.count < 3) else {
            throw CommonError.invalidAction(name: "Gameplay", reason: "There are already \(self.investors.count) investors")
        }
        // a player must have tokens remaining
        guard (player.tokens > 0) else {
            throw CommonError.invalidAction(name: "Gameplay", reason: "Player has no tokens remaining")
        }
        // add the investor
        self.investors.append(player)
    }
    public func removeInvestor(player: Player) {
        // Find the matching player in the investors array and pop the player from the array
        // Increment player tokens
    }
    
    public func payoutInvestors() throws {
        guard let ship = self.ship else {
            print ("No ship found")
            throw CommonError.invalidAction(name: "Gameplay", reason: "No ship found")
        }
        guard self.investors.count > 0 else {
            print ("No investors found")
            throw CommonError.invalidAction(name: "Gameplay", reason: "No investors found")
        }
        guard !isLocked else {
            print ("Dock is locked")
            throw CommonError.invalidAction(name: "Gameplay", reason: "Dock is locked")
        }
        guard ship.isReadyToSail else {
            print ("Ship \(ship.id) is not ready to sail")
            throw CommonError.invalidAction(name: "Gameplay", reason: "Ship is not ready to sail")
        }
        // Total up cargo cards on both sides
        let totalCargoCards = ship.totalCargoCards
        
        // Payout: A player is paid out `tokens they have` * `total cargo cards`
        //
        // print "Player credited: $coins"
        
        // Use the Bank to credit the player's account (don't set it directly)        
    }
}

final class PayoutInvestorsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here
    }

    override func tearDownWithError() throws {
        // Put teardown code here
    }

    func testNoShipFound() throws {
        
    }
    func testNoInvestorsFound() throws {
        
    }
    func testIsLocked() throws {
        
    }
    func testShipIsReadyToSail() throws {
        
    }
    func testExpectedPayout() throws {
        
    }

}
