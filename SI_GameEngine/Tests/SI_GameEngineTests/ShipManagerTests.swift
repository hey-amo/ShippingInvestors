//
//  ShipManagerTests.swift
//  SI_GameEngine
//
//  Created by Amarjit on 16/10/2025.
//

import XCTest
@testable import SI_GameEngine

/// Ship Manager
fileprivate struct ShipManager {
    private weak var ship: Ship?
    
    // Remove 'n' time cubes
    /// 1. Must be on a valid ship (not nil)
    /// 2. There must be positive integer in time cubes remaining
    public func removeTimeCube(_ amount: Int = 1) throws -> Ship? {
        guard let ship = ship else {
            print ("No ship found")
            throw CommonError.invalidAction(name: "Gameplay", reason: "No ship found")
        }
        guard (ship.timeCubesRemaining != 0) else {
            print ("This ship is at 0 time")
            throw CommonError.invalidAction(name: "Gameplay", reason: "Ship is at 0 time")
        }
        ship.timeCubesRemaining -= amount
        return ship
    }
    
    // Add 'n' cargo cards
    /// 1. Must be on a valid ship (not nil)
    /// 2. Cannot add 0 cargo cards
    /// 3. All cargo cards supplied must be same colour
    /// 4. Cannot add cargo cards if it exeeds card capacity (must be exact)
    /// 5. Cannot add cargo cards if it exceeds tonnage (must be exact)
    /// 6. When cargo cards are added, update the balance of the ship
    public func addCargo(cards: [CargoCard], side: Ship.Side) throws -> Ship {
        guard let ship = ship else {
            print ("No ship found")
            throw CommonError.invalidAction(name: "Gameplay", reason: "No ship found")
        }
        guard (cards.count > 0) else {
            print ("Cannot add 0 cargo cards")
            throw CommonError.invalidAction(name: "Gameplay", reason: "Cannot add 0 cargo cards")
        }
        // All cargo cards supplied must be same colour
                
        // Cannot add cards if its above its capacity of cards
        let sumCargo = (ship.cargo.count + cards.count)
        guard sumCargo <= ship.cardCapacity else {
            print ("Ship can only hold `\(ship.cardCapacity)` cards")
            throw CommonError.invalidAction(name: "Gameplay", reason: "Ship can only hold \(ship.cardCapacity) cards")
        }
        
        // Needs: Cannot add cards if its above its tonnage
        
        
        // Add cargo cards to the side the player selected
        ship.cargo[side]?.append(contentsOf: cards)
        
        return ship
    }
}

final class ShipManagerTests: XCTestCase {

    var ship: Ship?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.ship = Ship.prepareShips().first        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        ship = nil
    }
    
    func testTimeCube_NoShip_Fail() throws {
        
    }

    func testAddCargoCardsToShip_Fails() throws {
        
    }
    
    func testRemoveSingleTimeCube() throws {
        
    }
    
}
