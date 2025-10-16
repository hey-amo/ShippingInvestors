//
//  TurnOrderManager.swift
//  SI_GameEngine
//
//  Created by Amarjit on 14/10/2025.
//

/// Defines the requirements for an entity that can take turns
public protocol TurnTaking {
    var playerId: Int { get }
}

/// Defines the requirements for managing turns
public protocol TurnManaging {
    associatedtype Player: TurnTaking
    var activePlayer: Player { get }
    var players: [Player] { get }
    func nextTurn()
}

/// Manages turns
public class TurnOrderManager<P: TurnTaking>: TurnManaging {
    private var currentPlayerIndex: Int = 0
    public private(set) var players: [P]
    
    /// Initialise the turn manager with a list of players
    public init(players: [P]) {
        self.players = players.sorted { $0.playerId < $1.playerId }
    }
     /// Get the currently active player
    public var activePlayer: P {
        return players[currentPlayerIndex]
    }
    /// Advance to the next player's turn
    public func nextTurn() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    }
}
