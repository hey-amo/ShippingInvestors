//
//  GameModel.swift
//  ShippingMerchantsPkg
//
//  Created by Amarjit on 13/10/2025.
//

import Foundation

// Cargo card colours
public enum CargoCardColor: Int, Codable, CaseIterable {
    case red,yellow,blue,white,green,pink
}

// Cargo cards
public struct CargoCard: Identifiable, Equatable {
    public let id: UUID
    public let colour: CargoCardColor
    public let specialPower: Bool // TBD: IE: Clone the last card's weight, wild, etc.
    public let tonnage: Int // weight of the cargo
    public let coins: Int // coins when you sell this cargo to market
}

// Building cards
public struct BuildingCard: Identifiable, Equatable {
    public let id: UUID
}

// Weather categories
public enum WeatherCategories: Int, CaseIterable {
    case storms, bad, poor, calm, fine, good, perfect
}

// Destinations
public enum Destination: CaseIterable {
    case london, gothenburg, norway, copenhagen, hamburg
}

// Ship cards
public struct Ship: Identifiable, Equatable {
    public let id: UUID
    public let cardCapacity: Int // card capacity of the ship
    public let tonnage: Int // weight capacity of the ship
    public let timeCubesInitial: Int // initial time cubes for the ship
    public let timeCubes: Int // time cubes remaining on the ship
    public let cargo: [CargoCard] // cargo cards assigned to this ship
    public let destinations: Set<Destination> // a collection of non-repeating destinations
    public let balanceIndicator: Int // A fixed range from -4 to +4
    
    public var currentTonnage: Int {
        return 0 // this should be a reducer function to total the tonnage of cargo
    }
    
    public var isReadyToSail: Bool {
        // Ships that are ready to sail cannot be loaded anymore
        // The ship is ready to sail when either of the following are true:
        // is the currentTonnage == tonnage (must match exactly)
        // is the timeCubes at 0
        // is the cardCapacity reached
        return false
    }
    
    public static func == (left: Ship, right: Ship) -> Bool {
        return left.id == right.id
    }
}

public enum GameState: CaseIterable {
    case idle
    case gameSetup
    case playing
    case gameOver
}

public class Player: Identifiable {
    public let id: UUID
    public let cash: Int
    public let cards: [CargoCard]
    public let handSizeCapacity: Int
    public let tokens: Int
    public let avatar: String
    public let colorSchemeBG: String
    public let colorSchemeFG: String
    public let isAI: Bool
    public let isActivePlayer: Bool
    // need something to track each destinations the player has shipped to (0-5)
    
    init(id: UUID, cash: Int, cards: [CargoCard], handSizeCapacity: Int, tokens: Int, avatar: String, colorSchemeBG: String, colorSchemeFG: String, isAI: Bool = false, isActivePlayer: Bool = false) {
        self.id = id
        self.cash = cash
        self.cards = cards
        self.handSizeCapacity = handSizeCapacity
        self.tokens = tokens
        self.avatar = avatar
        self.colorSchemeBG = colorSchemeBG
        self.colorSchemeFG = colorSchemeFG
        self.isAI = isAI
        self.isActivePlayer = isActivePlayer
    }
}

/// The player gets 1 action per turn
public enum Actions: CaseIterable {
    case loadShipsWithCargo
    case investOrDivest // Invest tokens
    case sellCardsToMarket // Get coin value
    case buildImprovement // Add an improvement to a ship
    case pass // and get 1 coin
}

public enum GameMessageType: CaseIterable {
    case info, warning, error, other
}

public struct GameMessage {
    let message: String
    let messageType: GameMessageType
    let time: Date
}

// Timer for the game is the cargo card deck
public class GameModel {
    public var players: [Player]
    public var playerOnTurn: Int // index of active player
    public var gameState: GameState
    public var cargoCardDeck: [CargoCard] // deck of cargo cards
    public var cargoCardMarketplace: [CargoCard] // available cargo cards marketplace
    public var buildingDeck: [BuildingCard] // deck of building cards
    public var buildingMarketplace: [BuildingCard] // available buildings marketplace
    public var weather: Int // current weeather
    public var gameMessages: [GameMessage] // a log of game messages
    
    init(players: [Player], playerOnTurn: Int, gameState: GameState, cargoCardDeck: [CargoCard], cargoCardMarketplace: [CargoCard], buildingDeck: [BuildingCard], buildingMarketplace: [BuildingCard], weather: Int = 0, gameMessages: [GameMessage] = [GameMessage]()) {
        self.players = players
        self.playerOnTurn = playerOnTurn
        self.gameState = gameState
        self.cargoCardDeck = cargoCardDeck
        self.cargoCardMarketplace = cargoCardMarketplace
        self.buildingDeck = buildingDeck
        self.buildingMarketplace = buildingMarketplace
        self.weather = weather
        self.gameMessages = gameMessages
    }
}

// A struct to setup the game
public struct GameSetupManager {
    public func setup(for players: [Player]) {

        // Give each player 5 coins, 6 tokens
        // Randomly select 1 player to be on turn first
        // Prepare the cargo cards distribution
        // Randomly shuffle the cargo cards and give each player 3 cards each
        // Prepare a marketplace to get new cargo cards
        // Clear game messages array
    }
}


