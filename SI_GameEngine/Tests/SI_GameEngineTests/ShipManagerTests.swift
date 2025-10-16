//
//  ShipManagerTests.swift
//  SI_GameEngine
//
//  Created by Amarjit on 16/10/2025.
//

import XCTest
@testable import SI_GameEngine

fileprivate struct ShipManager {
    private weak var ship: Ship?
    
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
        let ships = Ship.prepareShips().first
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        ship = nil
    }
    
    func testTimeCube_NoShip_Fail() throws {
        
    }

    func testAddCargoCardsToShip() throws {
        
    }
    
}
