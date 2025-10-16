import Foundation

public enum ShipManagerError: Error, Equatable {
    case noShip
    case shipAtZeroTime
    case cannotAddZeroCards
    case mixedColours
    case capacityExceeded(max: Int)
    case tonnageExceeded(max: Int)
    case invalidAmount
}

/// Manages operations against a Ship instance 
public final class ShipManager {
    private var ship: Ship?

    public init(ship: Ship?) {
        self.ship = ship
    }

    /// Remove 'amount' time cubes from the current ship.
    /// - Throws: ShipManagerError when invalid
    /// - Returns: the updated Ship
    @discardableResult
    public func removeTimeCube(_ amount: Int = 1) throws -> Ship {
        guard let ship = ship else {
            throw ShipManagerError.noShip
        }
        guard amount > 0 else {
            throw ShipManagerError.invalidAmount
        }
        guard ship.timeCubesRemaining > 0 else {
            throw ShipManagerError.shipAtZeroTime
        }
        ship.timeCubesRemaining = max(0, ship.timeCubesRemaining - amount)
        return ship
    }

    /// Add cargo cards to a side of the ship validating colour, capacity and tonnage.
    /// - Throws: ShipManagerError on rules violation
    /// - Returns: the updated Ship
    @discardableResult
    public func addCargo(cards: [CargoCard], side: Ship.Side) throws -> Ship {
        guard let ship = ship else {
            throw ShipManagerError.noShip
        }
        guard cards.count > 0 else {
            throw ShipManagerError.cannotAddZeroCards
        }

        // All cargo cards must be same colour
        let firstColour = cards[0].colour
        if cards.contains(where: { $0.colour != firstColour }) {
            throw ShipManagerError.mixedColours
        }

        // Card capacity check (cardCapacity == -1 means unlimited)
        if ship.cardCapacity != -1 {
            let newTotalCards = ship.totalCargoCards + cards.count
            if newTotalCards > ship.cardCapacity {
                throw ShipManagerError.capacityExceeded(max: ship.cardCapacity)
            }
        }

        // Tonnage check (ship.tonnage == -1 means unlimited). Special cards with tonnage <= 0 are treated as 0 for tonnage checks.
        if ship.tonnage != -1 {
            let addedTonnage = cards.map { max(0, $0.tonnage) }.reduce(0, +)
            let newTonnage = ship.currentTonnage + addedTonnage
            if newTonnage > ship.tonnage {
                throw ShipManagerError.tonnageExceeded(max: ship.tonnage)
            }
        }

        ship.cargo[side, default: []].append(contentsOf: cards)

        return ship
    }
}