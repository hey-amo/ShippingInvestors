//
//  GameModel.swift
//  SI_GameEngine
//
//  Created by Amarjit on 14/10/2025.
//

import Foundation
import GameplayKit

// Game state
public enum GameState: CaseIterable {
    case idle, gameSetup, playing, gameOver
}

// Weather categories
public enum WeatherCategories: Int, CaseIterable {
    case storms, bad, poor, calm, fine, good, perfect
}

// Destinations
public enum Destination: CaseIterable {
    case london, malmo, norway, hamburg, copenhagen
}

// A player on their turn performs 1 of the following possible actions
public enum Actions: CaseIterable {
    case loadShipsWithCargo
    case investOrDivest // Invest tokens
    case sellCardsToMarket // Get coin value
    case buildImprovement // Add an improvement to a ship
    case pass // and get 1 coin -- this might be replaced by a loan action
    case drawCards // automatically happens
}

// Player avatars
public enum Avatar: CaseIterable {
    case avt_1, avt_2, avt_3, avt_4, avt_5

    public var imageName: String {
        switch self {
        case .avt_1:
            return "avt_1"
        case .avt_2:
            return "avt_2"
        case .avt_3:
            return "avt_3"
        case .avt_4:
            return "avt_4"
        case .avt_5:
            return "avt_5"
        }
    }
}

// ------------------------------------
// MARK: Player Model
// ------------------------------------

public class Player: NSObject, Identifiable, GKGameModelPlayer {
    public var playerId: Int
    public var coins: Int
    public var hand: [CargoCard]
    public let handSize: Int
    public var tokens: Int
    public let avatar: String
    public let isAI: Bool
    public let isActivePlayer: Bool

    // Tracks how many times this player has successfully delivered to each destination.
    // Values are clamped between 0 and maxDeliveries (default 5). Uses Destination.allCases
    // so adding/removing destinations automatically reflects in the default map.
    public private(set) var deliveries: [Destination: Int]
    public let maxDeliveriesPerDestination: Int
    
    init(playerId: Int,
         coins: Int,
         hand: [CargoCard] = [CargoCard](),
         handSize: Int,
         tokens: Int,
         avatar: Avatar,
         isAI: Bool,
         isActivePlayer: Bool,
         deliveries: [Destination: Int]? = nil,
         maxDeliveriesPerDestination: Int)
    {
        self.playerId = playerId
        self.coins = coins
        self.hand = hand
        self.handSize = handSize
        self.tokens = tokens
        self.avatar = avatar.imageName
        self.isAI = isAI
        self.isActivePlayer = isActivePlayer
        self.maxDeliveriesPerDestination = maxDeliveriesPerDestination
        
        // Initialize deliveries map. If the caller provides a map we merge it with all destinations
        // to ensure every Destination key exists. Otherwise create a fresh zeroed map for all cases.
        var base = Destination.allCases.reduce(into: [Destination: Int]()) { $0[$1] = 0 }
        if let provided = deliveries {
            for (k, v) in provided {
                base[k] = min(max(0, v), maxDeliveriesPerDestination)
            }
        }
        self.deliveries = base
    }
}

extension Player {
    // Returns current recorded deliveries for a destination (0..maxDeliveriesPerDestination)
    public func deliveredCount(for destination: Destination) -> Int {
        return deliveries[destination] ?? 0
    }

    // Record a delivery to a destination. `quantity` defaults to 1.
    // Returns the new recorded count (clamped to maxDeliveriesPerDestination).
    public func recordDelivery(to destination: Destination, quantity: Int = 1) -> Int {
        let current = deliveries[destination] ?? 0
        let new = min(maxDeliveriesPerDestination, current + max(0, quantity))
        deliveries[destination] = new
        return new
    }

    // Whether the player has completed the destination (reached maxDeliveriesPerDestination).
    public func hasCompleted(destination: Destination) -> Bool {
        return (deliveries[destination] ?? 0) >= maxDeliveriesPerDestination
    }

    // Reset all deliveries back to zero (keeps same destination keys).
    public func resetDeliveries() {
        for key in deliveries.keys {
            deliveries[key] = 0
        }
    }
}

// ------------------------------------
// MARK: Cargo Cards
// ------------------------------------

// Cargo card colours
public enum CargoCardColor: Int, Codable, CaseIterable {
    case red, yellow, green, blue, grey, white

    public var description: String {
        switch self {
        case .red:
            return "Red"
        case .yellow:
            return "Yellow"
        case .green:
            return "Green"
        case .blue:
            return "Blue"
        case .grey:
            return "grey"
        case .white:
            return "White"
        }
    }
}

// Cargo cards
public struct CargoCard: Identifiable, Equatable {
    public let id: UUID
    public let colour: CargoCardColor
    public let tonnage: Int // weight of the cargo
    public let special: Bool // does this card have a special effect? (clone)
}

extension CargoCard {
    public static func prepareCargoCards() -> [CargoCard] {
        // Create cargo cards, 12 of each colour, 2 in each colour are clone/special power
        // -1 means that the cargo is a clone card, and cannot be played by itself
        
        var cards: [CargoCard] = [CargoCard]()

        /*
        # CARGO CARDS
        | Colour | Weight Distribution |
        |--------|-------------------|
        | **Red (Coal)** | 4×[1t], 4×[2t], 2×[3t], 2×[=] |
        | **Blue (Iron)** | 3×[2t], 4×[3t], 3×[5t], 2×[=] |
        | **Yellow (Grain)** | 2×[1t], 6×[2t], 2×[3t], 2×[=] |
        | **Grey (Machinery)** | 2×[2t], 3×[3t], 3×[4t], 2×[6t], 2×[=] |
        | **Green (Timber)** | 5×[1t], 3×[2t], 2×[4t], 2×[=] |
        | **White (Wool)** | 6×[1t], 3×[2t], 1×[3t], 2×[=] |
        */
        
        // | **Red (Coal)** | 4×[1t], 4×[2t], 2×[3t], 2×[=] |
        let redCards = [
            // 4×[1t]
            CargoCard(id: UUID(), colour: .red, tonnage: 1, special: false),
            CargoCard(id: UUID(), colour: .red, tonnage: 1, special: false),
            CargoCard(id: UUID(), colour: .red, tonnage: 1, special: false),
            CargoCard(id: UUID(), colour: .red, tonnage: 1, special: false),
            // 4×[2t]
            CargoCard(id: UUID(), colour: .red, tonnage: 2, special: false),
            CargoCard(id: UUID(), colour: .red, tonnage: 2, special: false),
            CargoCard(id: UUID(), colour: .red, tonnage: 2, special: false),
            CargoCard(id: UUID(), colour: .red, tonnage: 2, special: false),
            // 2×[3t]
            CargoCard(id: UUID(), colour: .red, tonnage: 3, special: false),
            CargoCard(id: UUID(), colour: .red, tonnage: 3, special: false),
            // 2×[=]
            CargoCard(id: UUID(), colour: .red, tonnage: -1, special: true),
            CargoCard(id: UUID(), colour: .red, tonnage: -1, special: true),
        ]
        
        // | **Blue (Iron)** | 3×[2t], 4×[3t], 3×[5t], 2×[=] |
        let blueCards = [
            // 3×[2t]
            CargoCard(id: UUID(), colour: .blue, tonnage: 2, special: false),
            CargoCard(id: UUID(), colour: .blue, tonnage: 2, special: false),
            CargoCard(id: UUID(), colour: .blue, tonnage: 2, special: false),
            // 4×[3t]
            CargoCard(id: UUID(), colour: .blue, tonnage: 3, special: false),
            CargoCard(id: UUID(), colour: .blue, tonnage: 3, special: false),
            CargoCard(id: UUID(), colour: .blue, tonnage: 3, special: false),
            CargoCard(id: UUID(), colour: .blue, tonnage: 3, special: false),
            // 3×[5t]
            CargoCard(id: UUID(), colour: .blue, tonnage: 5, special: false),
            CargoCard(id: UUID(), colour: .blue, tonnage: 5, special: false),
            CargoCard(id: UUID(), colour: .blue, tonnage: 5, special: false),
            // 2×[=]
            CargoCard(id: UUID(), colour: .blue, tonnage: -1, special: true),
            CargoCard(id: UUID(), colour: .blue, tonnage: -1, special: true),
        ]
        
        //| **Yellow (Grain)** | 2×[1t], 6×[2t], 2×[3t], 2×[=] |
        let yellowCards = [
            // 2×[1t]
            CargoCard(id: UUID(), colour: .yellow, tonnage: 1, special: false),
            CargoCard(id: UUID(), colour: .yellow, tonnage: 1, special: false),
            // 6×[2t]
            CargoCard(id: UUID(), colour: .yellow, tonnage: 2, special: false),
            CargoCard(id: UUID(), colour: .yellow, tonnage: 2, special: false),
            CargoCard(id: UUID(), colour: .yellow, tonnage: 2, special: false),
            CargoCard(id: UUID(), colour: .yellow, tonnage: 2, special: false),
            CargoCard(id: UUID(), colour: .yellow, tonnage: 2, special: false),
            CargoCard(id: UUID(), colour: .yellow, tonnage: 2, special: false),
            // 2×[3t]
            CargoCard(id: UUID(), colour: .yellow, tonnage: 3, special: false),
            CargoCard(id: UUID(), colour: .yellow, tonnage: 3, special: false),
            // 2×[=]
            CargoCard(id: UUID(), colour: .yellow, tonnage: -1, special: true),
            CargoCard(id: UUID(), colour: .yellow, tonnage: -1, special: true),
        ]

        // | **Grey (Machinery)** | 2×[2t], 3×[3t], 3×[4t], 2×[6t], 2×[=] |
        let greyCards = [
            // 2×[2t]
            CargoCard(id: UUID(), colour: .grey, tonnage: 2, special: false),
            CargoCard(id: UUID(), colour: .grey, tonnage: 2, special: false),
            // 3×[3t]
            CargoCard(id: UUID(), colour: .grey, tonnage: 3, special: false),
            CargoCard(id: UUID(), colour: .grey, tonnage: 3, special: false),
            CargoCard(id: UUID(), colour: .grey, tonnage: 3, special: false),
            // 3×[4t]
            CargoCard(id: UUID(), colour: .grey, tonnage: 4, special: false),
            CargoCard(id: UUID(), colour: .grey, tonnage: 4, special: false),
            CargoCard(id: UUID(), colour: .grey, tonnage: 4, special: false),
            // 2×[6t]
            CargoCard(id: UUID(), colour: .grey, tonnage: 6, special: false),
            CargoCard(id: UUID(), colour: .grey, tonnage: 6, special: false),
            // 2×[=]
            CargoCard(id: UUID(), colour: .grey, tonnage: -1, special: true),
            CargoCard(id: UUID(), colour: .grey, tonnage: -1, special: true),
        ]
        
        // | **Green (Timber)** | 5×[1t], 3×[2t], 2×[4t], 2×[=] |
        let greenCards = [
            // 5×[1t]
            CargoCard(id: UUID(), colour: .green, tonnage: 1, special: false),
            CargoCard(id: UUID(), colour: .green, tonnage: 1, special: false),
            CargoCard(id: UUID(), colour: .green, tonnage: 1, special: false),
            CargoCard(id: UUID(), colour: .green, tonnage: 1, special: false),
            CargoCard(id: UUID(), colour: .green, tonnage: 1, special: false),
            // 3×[2t]
            CargoCard(id: UUID(), colour: .green, tonnage: 2, special: false),
            CargoCard(id: UUID(), colour: .green, tonnage: 2, special: false),
            CargoCard(id: UUID(), colour: .green, tonnage: 2, special: false),
            // 2×[4t]
            CargoCard(id: UUID(), colour: .green, tonnage: 4, special: false),
            CargoCard(id: UUID(), colour: .green, tonnage: 4, special: false),
            // 2×[=]
            CargoCard(id: UUID(), colour: .green, tonnage: -1, special: true),
            CargoCard(id: UUID(), colour: .green, tonnage: -1, special: true),
        ]
        
        // | **White (Wool)** | 6×[1t], 3×[2t], 1×[3t], 2×[=] |
        let whiteCards = [
            // 6×[1t]
            CargoCard(id: UUID(), colour: .white, tonnage: 1, special: false),
            CargoCard(id: UUID(), colour: .white, tonnage: 1, special: false),
            CargoCard(id: UUID(), colour: .white, tonnage: 1, special: false),
            CargoCard(id: UUID(), colour: .white, tonnage: 1, special: false),
            CargoCard(id: UUID(), colour: .white, tonnage: 1, special: false),
            CargoCard(id: UUID(), colour: .white, tonnage: 1, special: false),
            // 3×[2t]
            CargoCard(id: UUID(), colour: .white, tonnage: 2, special: false),
            CargoCard(id: UUID(), colour: .white, tonnage: 2, special: false),
            CargoCard(id: UUID(), colour: .white, tonnage: 2, special: false),
            // 1×[3t]
            CargoCard(id: UUID(), colour: .white, tonnage: 3, special: false),
            // 2×[=]
            CargoCard(id: UUID(), colour: .white, tonnage: -1, special: true),
            CargoCard(id: UUID(), colour: .white, tonnage: -1, special: true),
        ]
        
        // Append all cards
        cards.append(contentsOf: redCards)
        cards.append(contentsOf: blueCards)
        cards.append(contentsOf: yellowCards)
        cards.append(contentsOf: greyCards)
        cards.append(contentsOf: greenCards)
        cards.append(contentsOf: whiteCards)
        
        // Shuffle the cargo cards
        let shuffledCards = cards.shuffled()
        print("Prepared and shuffled \(shuffledCards.count) cargo cards.")

        return shuffledCards
    }
}

// ------------------------------------
// MARK: Building Cards
// ------------------------------------

// Building cards
public struct BuildingCard: Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let description: String
    public let cost: Int // cost to build this improvement
    public let effect: String // description of the effect of this improvement
    public let imageName: String // name of the image asset for this building
    public let passiveOrActive: Bool // whether the building has a passive or active effect
}

extension BuildingCard {
    public static func prepareBuildingCards() -> [BuildingCard] {
        // Create 10 building cards with varying costs and effects
        let buildings: [BuildingCard] = [
            BuildingCard(id: UUID(), name: "Crane", description: "Move 1 cargo card to another ship.", cost: 5, effect: "Move 1 cargo", imageName: "crane", passiveOrActive: true),
            BuildingCard(id: UUID(), name: "Office", description: "Gain 2 coins when delivering.", cost: 6, effect: "Payout Bonus +2", imageName: "luxury_cabins", passiveOrActive: false),
            BuildingCard(id: UUID(), name: "Reinforced Hull", description: "Increase tonnage capacity by 2.", cost: 8, effect: "Tonnage +2", imageName: "reinforced_hull", passiveOrActive: false),
            BuildingCard(id: UUID(), name: "Warehouse", description: "Increase card capacity by 2.", cost: 7, effect: "Card Capacity +2", imageName: "warehouse", passiveOrActive: false),
            BuildingCard(id: UUID(), name: "Lighthouse", description: "Ignore bad weather effects once per game.", cost: 10, effect: "Ignore Weather", imageName: "weather_radar", passiveOrActive: true),
            BuildingCard(id: UUID(), name: "Customs House", description: "Add 3 time cubes to 1 ship", cost: 7, effect: "Add Time Cubes +3", imageName: "customs_house", passiveOrActive: true),
            BuildingCard(id: UUID(), name: "Luxury Cabins", description: "Gain 1 coin when passing.", cost: 4, effect: "Pass Bonus +1", imageName: "office", passiveOrActive: false),
            BuildingCard(id: UUID(), name: "Ropery", description: "May load 1 cargo card for free.", cost: 9, effect: "Load 1 cargo free", imageName: "roperty", passiveOrActive: true),
            BuildingCard(id: UUID(), name: "Sail Loft", description: "Increase tolerance by 1.", cost: 6, effect: "Tolerance +1", imageName: "sail_loft", passiveOrActive: false),
            BuildingCard(id: UUID(), name: "Extra Crew", description: "Add 1 time cube to this ship.", cost: 5, effect: "Add Time Cubes +1", imageName: "extra_crew", passiveOrActive: false),
        ]
        
        // Shuffle the building cards
        let shuffledBuildings = buildings.shuffled()
        print ("Prepared and shuffled \(shuffledBuildings.count) building cards.")
        return shuffledBuildings
    }
}

// ------------------------------------
// MARK: Docks
// ------------------------------------

// 4 Docks or Shipping Lanes in the game, but only 3 are used until the 4th is unlocked
// Shipping lanes
public struct Dock {
    public let id: UUID
    public var improvements: [BuildingCard] // a collection of building cards (improvements)
    public var investors: [Player] // a collection of players who have invested in this lane - limited 3 seats. A player can have 0, or multiple seats.
    public var ship: Ship? // the ship currently at this lane (if any)
    public var isLocked: Bool // whether the lane is locked or unlocked
}

extension Dock {
    public static func prepareDocks() -> [Dock] {
        let docks = [
            Dock(id: UUID(), improvements: [], investors: [], ship: nil, isLocked: false),
            Dock(id: UUID(), improvements: [], investors: [], ship: nil, isLocked: false),
            Dock(id: UUID(), improvements: [], investors: [], ship: nil, isLocked: false),
            Dock(id: UUID(), improvements: [], investors: [], ship: nil, isLocked: true),
        ]
        return docks
    }
}

// ------------------------------------
// MARK: Ship model
// ------------------------------------

// Ships can never have tonnage or cargo cards more than their capacity
public struct Ship: Identifiable, Equatable {
    public enum Side: CaseIterable, Hashable {
        case left, right
    }
    
    public let id: Int
    public let tonnage: Int // weight capacity of the ship
    public let cardCapacity: Int // card capacity of the ship
    public let timeCubesInitial: Int // initial time cubes for the ship
    public let timeCubesRemaining: Int // time remaining at port
    
    public var cargo: [Side: [CargoCard]] // a dictionary of sides and their cargo cards
    public let destinations: Set<Destination> // a collection of non-repeating destinations
    
    public let balanceIndicator: Int // A fixed range from -4 to +4
    public let tolerance: Int // the range in which the ship is balanced.
        
    // total tonnage currently on the ship (sum of all cargo cards' tonnage)
    public var currentTonnage: Int {
        return cargo.values.flatMap { $0 }.reduce(0) { $0 + $1.tonnage }
    }

    // total number of cargo cards currently on the ship
    public var totalCargoCards: Int {
        return cargo.values.reduce(0) { $0 + $1.count }
    }

    // how much tonnage capacity remains (never negative)
    public var tonnageRemaining: Int {
        return max(0, tonnage - currentTonnage)
    }

    // how many more cards can be placed on this ship (never negative)
    public var cardsRemaining: Int {
        return max(0, cardCapacity - totalCargoCards)
    }

     public var isReadyToSail: Bool {
        // Ships that are ready to sail cannot be loaded anymore
        // The ship is ready to sail when any of the following are true:
        // - currentTonnage == tonnage (exact match)
        // - timeCubes == 0
        // - cardCapacity reached
        return currentTonnage == tonnage || timeCubesRemaining == 0 || totalCargoCards >= cardCapacity
    }
    
    public init(id: Int,
                tonnage: Int,
                cardCapacity: Int,
                timeCubesInitial: Int,
                timeCubesRemaining: Int,
                cargoLeft: [CargoCard],
                cargoRight: [CargoCard],
                destinations: Set<Destination>,
                balanceIndicator: Int,
                tolerance: Int)
    {
        self.id = id
        self.tonnage = tonnage
        self.cardCapacity = cardCapacity
        self.timeCubesInitial = timeCubesInitial
        self.timeCubesRemaining = timeCubesRemaining
        self.cargo = [.left: cargoLeft, .right: cargoRight]
        self.destinations = destinations
        self.balanceIndicator = balanceIndicator
        self.tolerance = tolerance
    }
    
    public static func == (left: Ship, right: Ship) -> Bool {
        return (left.id == right.id)
    }
}

extension Ship {
    public static func prepareShips() -> [Ship] {
        // Create 18 ships with varying capacities, tonnage, time cubes, destinations
        // If a ship has -1 tonnage, it means that it doesn't care about the tonnage
        // If a ship has -1 cardCapacity, it means that it doesn't care about the card capacity
        // Shuffle the ships
        let ships: [Ship] = [
            Ship(id: 1, tonnage: 6, cardCapacity: 3, timeCubesInitial: 4, timeCubesRemaining: 4, cargoLeft: [], cargoRight: [], destinations: [.malmo, .norway], balanceIndicator: 0, tolerance: 1),
            Ship(id: 2, tonnage: 6, cardCapacity: 4, timeCubesInitial: 3, timeCubesRemaining: 3, cargoLeft: [], cargoRight: [], destinations: [.copenhagen, .hamburg], balanceIndicator: 0, tolerance: 2),
            Ship(id: 3, tonnage: 6, cardCapacity: 5, timeCubesInitial: 4, timeCubesRemaining: 4, cargoLeft: [], cargoRight: [], destinations: [.london, .malmo], balanceIndicator: 0, tolerance: 1),
            Ship(id: 4, tonnage: -1, cardCapacity: 3, timeCubesInitial: 3, timeCubesRemaining: 3, cargoLeft: [], cargoRight: [], destinations: [.norway, .copenhagen], balanceIndicator: 0, tolerance: 3),
            Ship(id: 5, tonnage: 8, cardCapacity: -1, timeCubesInitial: 4, timeCubesRemaining: 4, cargoLeft: [], cargoRight: [], destinations: [.hamburg, .london], balanceIndicator: 0, tolerance: 3),
            Ship(id: 6, tonnage: 8, cardCapacity: 4, timeCubesInitial: 4, timeCubesRemaining: 4, cargoLeft: [], cargoRight: [], destinations: [.malmo, .hamburg], balanceIndicator: 0, tolerance: 2),
            Ship(id: 7, tonnage: 8, cardCapacity: 6, timeCubesInitial: 5, timeCubesRemaining: 5, cargoLeft: [], cargoRight: [], destinations: [.copenhagen, .norway], balanceIndicator: 0, tolerance: 2),
            Ship(id: 8, tonnage: -1, cardCapacity: 4, timeCubesInitial: 3, timeCubesRemaining: 3, cargoLeft: [], cargoRight: [], destinations: [.london, .copenhagen], balanceIndicator: 0, tolerance: 2),
            Ship(id: 9, tonnage: 10, cardCapacity: 7, timeCubesInitial: 3, timeCubesRemaining: 5, cargoLeft: [], cargoRight: [], destinations: [.malmo, .london], balanceIndicator: 0, tolerance: 1),
            Ship(id: 10, tonnage: 10, cardCapacity: 8, timeCubesInitial: 3, timeCubesRemaining: 5, cargoLeft: [], cargoRight: [], destinations: [.norway, .hamburg], balanceIndicator: 0, tolerance: 2),
            Ship(id: 11, tonnage: 10, cardCapacity: -1, timeCubesInitial: 3, timeCubesRemaining: 4, cargoLeft: [], cargoRight: [], destinations: [.copenhagen, .malmo], balanceIndicator: 0, tolerance: 2),
            Ship(id: 12, tonnage: 12, cardCapacity: 5, timeCubesInitial: 3, timeCubesRemaining: 5, cargoLeft: [], cargoRight: [], destinations: [.hamburg, .norway], balanceIndicator: 0, tolerance: 1),
            Ship(id: 13, tonnage: 12, cardCapacity: 6, timeCubesInitial: 3, timeCubesRemaining: 5, cargoLeft: [], cargoRight: [], destinations: [.london, .norway], balanceIndicator: 0, tolerance: 2),
            Ship(id: 14, tonnage: 12, cardCapacity: -1, timeCubesInitial: 3, timeCubesRemaining: 5, cargoLeft: [], cargoRight: [], destinations: [.malmo, .copenhagen], balanceIndicator: 0, tolerance: 3),
            Ship(id: 15, tonnage: 12, cardCapacity: -1, timeCubesInitial: 3, timeCubesRemaining: 5, cargoLeft: [], cargoRight: [], destinations: [.hamburg, .malmo], balanceIndicator: 0, tolerance: 1),
            Ship(id: 16, tonnage: 15, cardCapacity: 6, timeCubesInitial: 3, timeCubesRemaining: 5, cargoLeft: [], cargoRight: [], destinations: [.norway, .london], balanceIndicator: 0, tolerance: 2),
            Ship(id: 17, tonnage: 15, cardCapacity: 8, timeCubesInitial: 3, timeCubesRemaining: 6, cargoLeft: [], cargoRight: [], destinations: [.copenhagen, .hamburg], balanceIndicator: 0, tolerance: 2),
            Ship(id: 18, tonnage: -1, cardCapacity: 8, timeCubesInitial: 3, timeCubesRemaining: 6, cargoLeft: [], cargoRight: [], destinations: [.london, .hamburg], balanceIndicator: 0, tolerance: 3),
        ]

        // Shuffle the ships
        let shuffledShips = ships.shuffled()
        print("Prepared and shuffled \(shuffledShips.count) ships.")
        return shuffledShips
    }
}

// ------------------------------------
// MARK: Game model
// ------------------------------------

// Game timer is the CargoDeck
public class GameModel {
    public var gameState: GameState
    public var players: [Player]
    public var playerOnTurn: Int // index of active player
    public var cargoDeck: [CargoCard]
    public var cargoMarketplace: [CargoCard]
    public var buildingDeck: [BuildingCard]
    public var weather: Int // current weather
    public var shipDeck: [Ship] // deck of ships remaining in the game
    public var shipDiscardDeck: [Ship] // discard pile for deck of ships
    public var docks: [Dock] // 4 shipping lanes
    
    // Message storage is delegated to GameMessageStore
    public let messageStore: GameMessageStore

    // Public read-only view (always newest-first)
    public var gameMessages: [GameMessage] { messageStore.newestFirst }
    
    public init(
        gameState: GameState,
        players: [Player],
        playerOnTurn: Int,
        cargoDeck: [CargoCard],
        cargoMarketplace: [CargoCard],
        buildingDeck: [BuildingCard],
        weather: Int,
        shipDeck: [Ship],
        shipDiscardDeck: [Ship],
        docks: [Dock],
        messageStore: GameMessageStore = GameMessageStore()
    ) {
        self.gameState = gameState
        self.players = players
        self.playerOnTurn = playerOnTurn
        self.cargoDeck = cargoDeck
        self.cargoMarketplace = cargoMarketplace
        self.buildingDeck = buildingDeck
        self.weather = weather
        self.shipDeck = shipDeck
        self.shipDiscardDeck = shipDiscardDeck
        self.docks = docks
        self.messageStore = messageStore
    }
}

// ------------------------------------
// MARK: Game Setup Manager
// ------------------------------------

public struct GameSetupManager {
    public func setup(for players: [Player]) -> GameModel? {
        let players = players
        guard players.count >= 2 && players.count <= 5 else {
            print ("Error: Number of players must be between 2 and 5.")
            return nil
        }

        print("Setting up game for \(players.count) players.")
        let cargoDeck: [CargoCard] = CargoCard.prepareCargoCards()
        let shipDeck: [Ship] = Ship.prepareShips()
        let buildingCards: [BuildingCard] = BuildingCard.prepareBuildingCards()
        let cargoMarketplace: [CargoCard] = []
        let shipDiscardDeck: [Ship] = []
        let docks: [Dock] = Dock.prepareDocks()
        let weather: Int = 0
        
        print("Preparing game model.")
        let gameModel = GameModel(gameState: .gameSetup, players: players, playerOnTurn: 0, cargoDeck: cargoDeck, cargoMarketplace: cargoMarketplace, buildingDeck: buildingCards, weather: weather, shipDeck: shipDeck, shipDiscardDeck: shipDiscardDeck, docks: docks)
        
        return gameModel
    }
}

