//
//  ShipManagerTests.swift
//  SI_GameEngine
//
//  Created by Amarjit on 16/10/2025.
//

import XCTest
@testable import SI_GameEngine

final class ShipManagerTests: XCTestCase {

    // Helper to create a deterministic ship for tests
    private func makeShip(id: Int = 999,
                          tonnage: Int = 10,
                          cardCapacity: Int = 4,
                          timeCubesRemaining: Int = 3,
                          left: [CargoCard] = [],
                          right: [CargoCard] = []) -> Ship
    {
        return Ship(id: id,
                    tonnage: tonnage,
                    cardCapacity: cardCapacity,
                    timeCubesInitial: timeCubesRemaining,
                    timeCubesRemaining: timeCubesRemaining,
                    cargoLeft: left,
                    cargoRight: right,
                    destinations: [.london],
                    balanceIndicator: 0,
                    tolerance: 1)
    }

    func testTimeCube_NoShip_Fail() throws {
        let manager = ShipManager(ship: nil)
        XCTAssertThrowsError(try manager.removeTimeCube()) { error in
            XCTAssertEqual(error as? ShipManagerError, ShipManagerError.noShip)
        }
    }

    func testRemoveSingleTimeCube() throws {
        let ship = makeShip(timeCubesRemaining: 2)
        let manager = ShipManager(ship: ship)

        let updated = try manager.removeTimeCube()
        XCTAssertEqual(updated.timeCubesRemaining, 1)
        // remove again to zero
        let updated2 = try manager.removeTimeCube()
        XCTAssertEqual(updated2.timeCubesRemaining, 0)
        // now further removals should error with shipAtZeroTime
        XCTAssertThrowsError(try manager.removeTimeCube()) { error in
            XCTAssertEqual(error as? ShipManagerError, ShipManagerError.shipAtZeroTime)
        }
    }

    func testAddCargoCardsToShip_Fails() throws {
        // Prepare cards
        let red1 = CargoCard(id: UUID(), colour: .red, tonnage: 2, special: false)
        let red2 = CargoCard(id: UUID(), colour: .red, tonnage: 2, special: false)
        let blue1 = CargoCard(id: UUID(), colour: .blue, tonnage: 2, special: false)

        // 1) No ship
        var manager = ShipManager(ship: nil)
        XCTAssertThrowsError(try manager.addCargo(cards: [red1], side: .left)) { error in
            XCTAssertEqual(error as? ShipManagerError, ShipManagerError.noShip)
        }

        // 2) Cannot add zero cards
        let ship1 = makeShip(tonnage: 10, cardCapacity: 4)
        manager = ShipManager(ship: ship1)
        XCTAssertThrowsError(try manager.addCargo(cards: [], side: .left)) { error in
            XCTAssertEqual(error as? ShipManagerError, ShipManagerError.cannotAddZeroCards)
        }

        // 3) Mixed colours
        XCTAssertThrowsError(try manager.addCargo(cards: [red1, blue1], side: .left)) { error in
            XCTAssertEqual(error as? ShipManagerError, ShipManagerError.mixedColours)
        }

        // 4) Capacity exceeded
        let ship2 = makeShip(tonnage: 10, cardCapacity: 2, left: [red1]) // already 1 card on left
        manager = ShipManager(ship: ship2)
        // trying to add 2 cards will exceed capacity 2 (1 existing + 2 > 2)
        XCTAssertThrowsError(try manager.addCargo(cards: [red1, red2], side: .left)) { error in
            // unwrap then match enum case
            guard let shipError = error as? ShipManagerError else {
                return XCTFail("Unexpected error type")
            }
            if case let .capacityExceeded(max) = shipError {
                XCTAssertEqual(max, 2)
            } else {
                XCTFail("Expected capacityExceeded error")
            }
        }

        // 5) Tonnage exceeded
        let ship3 = makeShip(tonnage: 3, cardCapacity: 10) // small tonnage
        manager = ShipManager(ship: ship3)
        // adding a card of tonnage 2 twice (4) will exceed 3
        XCTAssertThrowsError(try manager.addCargo(cards: [red1, red2], side: .right)) { error in
            guard let shipError = error as? ShipManagerError else {
                return XCTFail("Unexpected error type")
            }
            if case let .tonnageExceeded(max) = shipError {
                XCTAssertEqual(max, 3)
            } else {
                XCTFail("Expected tonnageExceeded error")
            }
        }

        // 6) Successful add should not throw
        let ship4 = makeShip(tonnage: 10, cardCapacity: 5)
        manager = ShipManager(ship: ship4)
        XCTAssertNoThrow(try manager.addCargo(cards: [red1, red2], side: .left))
        XCTAssertEqual(ship4.totalCargoCards, 2)
        // cargo appended to left side
        XCTAssertEqual(ship4.cargo[.left]?.count, 2)

    }
}