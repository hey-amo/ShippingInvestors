//
//  GameModel.swift
//  ShippingMerchantsPkg
//
//  Created by Amarjit on 13/10/2025.
//

import Foundation

// Cargo card colours
public enum CargoCardColor: Int, Codable, CaseIterable {
    case red, yellow, green, blue, white, purple

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
        case .white:
            return "White"
        case .purple:
            return "Purple"
        }
    }
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
    public let name: String
    public let description: String
    public let cost: Int // cost to build this improvement
    public let effect: String // description of the effect of this improvement
    public let imageName: String // name of the image asset for this building
    public let passiveOrActive: Bool // whether the building has a passive or active effect
}

// Weather categories
public enum WeatherCategories: Int, CaseIterable {
    case storms, bad, poor, calm, fine, good, perfect
}

// Destinations
public enum Destination: CaseIterable {
    case london, gothenburg, norway, copenhagen, hamburg
}

// 4 Docks or Shipping Lanes in the game, but only 3 are used until the 4th is unlocked
// Shipping lanes
public struct Docks {
    public let id: UUID
    public var improvements: [BuildingCard] // a collection of building cards (improvements)
    public var investors: [Player] // a collection of players who have invested in this lane
    public var ship: Ship? // the ship currently at this lane (if any)
    public var isLocked: Bool // whether the lane is locked or unlocked
}

// MARK: Ship model

// Ships can never have tonnage or cargo cards more than their capacity
// Ship cards
public struct Ship: Identifiable, Equatable {
    public enum Side: CaseIterable, Hashable {
        case left, right
    }

    public let id: Int
    public let cardCapacity: Int // card capacity of the ship
    public let tonnage: Int // weight capacity of the ship
    public let timeCubesInitial: Int // initial time cubes for the ship
    public let timeCubes: Int // time remaining at port
    
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
        return currentTonnage == tonnage || timeCubes == 0 || totalCargoCards >= cardCapacity
    }

     public init(id: Int,
                cardCapacity: Int,
                tonnage: Int,
                timeCubesInitial: Int,
                timeCubes: Int,
                cargoLeft: [CargoCard] = [],
                cargoRight: [CargoCard] = [],
                destinations: Set<Destination> = [],
                balanceIndicator: Int = 0,
                tolerance: Int = 0) {
        self.id = id
        self.cardCapacity = cardCapacity
        self.tonnage = tonnage
        self.timeCubesInitial = timeCubesInitial
        self.timeCubes = timeCubes
        self.cargo = [.left: cargoLeft, .right: cargoRight]
        self.destinations = destinations
        self.balanceIndicator = balanceIndicator
        self.tolerance = tolerance
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

// MARK: Player model

public class Player: Identifiable {
    public let id: UUID
    public let cash: Int
    public let cards: [CargoCard]
    public let handSizeCapacity: Int // 3,5,7
    public let tokens: Int
    public let avatar: String
    public let colorSchemeBG: String
    public let colorSchemeFG: String
    public let isAI: Bool
    public let isActivePlayer: Bool

    public var handSize: Int {
        return cards.count
    }
    
    // Tracks how many times this player has successfully delivered to each destination.
    // Values are clamped between 0 and maxDeliveries (default 5). Uses Destination.allCases
    // so adding/removing destinations automatically reflects in the default map.
    public private(set) var deliveries: [Destination: Int]
    public let maxDeliveriesPerDestination: Int
    
public init(
        id: UUID,
        cash: Int,
        cards: [CargoCard],
        handSizeCapacity: Int,
        tokens: Int,
        avatar: String,
        colorSchemeBG: String,
        colorSchemeFG: String,
        isAI: Bool = false,
        isActivePlayer: Bool = false,
        deliveries: [Destination: Int]? = nil,
        maxDeliveriesPerDestination: Int = 5
    ) {
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
    public let message: String
    public let messageType: GameMessageType
    public let time: Date

    public init(message: String, messageType: GameMessageType = .info, time: Date = Date()) {
        self.message = message
        self.messageType = messageType
        self.time = time
    }
}

/// Responsible for storing, trimming and exposing game messages.
/// Keeps newest-first ordering, trims oldest messages when capacity exceeded,
/// and provides clear() functionality.
public final class GameMessageStore {
    private(set) var messages: [GameMessage] = []
    public static let maxMessages: Int = 50

    public init(messages: [GameMessage] = []) {
        // keep newest-first and trim to capacity
        let ordered = messages.sorted { $0.time > $1.time }
        if ordered.count > Self.maxMessages {
            self.messages = Array(ordered.prefix(Self.maxMessages))
        } else {
            self.messages = ordered
        }
    }

    // Add a timestamped text message
    public func add(_ text: String, type: GameMessageType = .info) {
        add(GameMessage(message: text, messageType: type, time: Date()))
    }

    // Add a GameMessage instance; ensures newest-first order and trims oldest by date
    public func add(_ message: GameMessage) {
        messages.append(message)
        messages.sort { $0.time > $1.time } // newest first
        if messages.count > Self.maxMessages {
            messages = Array(messages.prefix(Self.maxMessages))
        }
    }

    // Remove all messages
    public func clear() {
        messages.removeAll()
    }

    // Read-only view (newest-first)
    public var newestFirst: [GameMessage] { messages }
    public var count: Int { messages.count }
}


// MARK: Game model

public class GameModel {
    public var players: [Player]
    public var playerOnTurn: Int // index of active player
    public var gameState: GameState
    public var cargoCardDeck: [CargoCard] // deck of cargo cards
    public var cargoCardMarketplace: [CargoCard] // available cargo cards marketplace
    public var buildingDeck: [BuildingCard] // deck of building cards
    public var buildingMarketplace: [BuildingCard] // available buildings marketplace
    public var weather: Int // current weeather
    public var shipsDeck: [Ship] // deck of ships
    public var docks: [Docks] // 4 shipping lanes / docks
    
    // Message storage is delegated to GameMessageStore 
    public let messageStore: GameMessageStore

    // Public read-only view (always newest-first)
    public var gameMessages: [GameMessage] { messageStore.newestFirst }
    
    init(players: [Player], playerOnTurn: Int, gameState: GameState, cargoCardDeck: [CargoCard], cargoCardMarketplace: [CargoCard], buildingDeck: [BuildingCard], buildingMarketplace: [BuildingCard], weather: Int = 0, gameMessages: [GameMessage] = [GameMessage](), docks: [Docks] = [Docks](), messageStore: GameMessageStore = GameMessageStore(), shipsDeck: [Ship] = [Ship]()) {
        self.players = players
        self.playerOnTurn = playerOnTurn
        self.gameState = gameState
        self.cargoCardDeck = cargoCardDeck
        self.cargoCardMarketplace = cargoCardMarketplace
        self.buildingDeck = buildingDeck
        self.buildingMarketplace = buildingMarketplace
        self.weather = weather
        self.messageStore = messageStore
        self.docks = docks
        self.shipsDeck = shipsDeck
    }
}

// MARK: Bank model

public struct Bank {
    private var _balance: Int 
    public var balance: Int {
        return _balance
    }
    public mutating func credit(amount: Int) {
        // Add amount to balance
        guard canCredit(amount: amount) else { return }
        self._balance += amount
    }
    public mutating func debit(amount: Int) {
        // Subtract amount from balance
        guard canDebit(amount: amount) else { return }
        self._balance -= amount
    }
    public func canDebit(amount: Int) -> Bool {
        guard amount >= 0 else { return false }
        guard balance >= amount else { return false }
        let sum = balance - amount
        guard sum >= 0 else { return false }
        return true
    }
    public func canCredit(amount: Int) -> Bool {
        guard amount >= 0 else { return false }
        return true
    }
}


// A struct to setup the game
public struct GameSetupManager {
    public func setup(for players: [Player]) -> GameModel? {
        guard players.count >= 2 && players.count <= 5 else {
            print ("Error: Number of players must be between 2 and 5.")
            return nil
        }
        // Initialize the game model with the following steps:
        // Create players with unique colours and avatars
        // Player hand size capacity is 3
        // Give each player 5 coins, 6 tokens in their colour
        // Randomly select 1 player to be on turn first
        // Prepare the cargo cards (60 cards, 10 of each colour) distribution
        // Randomly shuffle the cargo cards and give each player 3 cards each
        // Prepare a marketplace to get new cargo cards
        // Create 18 ships
        // Create the 4 shipping lanes, with 3 unlocked and 1 locked
        // Clear game messages array

        print("Setting up game for \(players.count) players.")
        prepareCargoCards()
        prepareCargoMarketplace()
        let ships: [Ship] = prepareShips()
        prepareBuildingCards()
        prepareBuildingCardMarketplace()
        prepareDocks()
        let initialWeather: Int = 0 // initial weather
        // randomly select a player to start first
        let startingPlayerIndex = Int.random(in: 0..<players.count)
        print ("Player \(players[startingPlayerIndex].id) will start first.")

        // Initialize a new game model
        let gameModel: GameModel = GameModel(
            players: players,
            playerOnTurn: startingPlayerIndex,
            gameState: .gameSetup,
            shipsDeck: ships,
            cargoCardDeck: [],
            cargoCardMarketplace: [],
            buildingDeck: [],
            buildingMarketplace: [],
            weather: initialWeather,
            gameMessages: [],
            docks: [],
            messageStore: GameMessageStore()
        )

        return gameModel
    }
    
    private func prepareCargoCards() {
        // Create 60 cargo cards, 10 of each colour, 2 in each colour are clone/special power

        var cards: [CargoCard] = []

        for color in CargoCardColor.allCases {
            for _ in 1...8 {
                let card = CargoCard(id: UUID(), colour: color, specialPower: false, tonnage: Int.random(in: 1...5), coins: Int.random(in: 1...5))
                // Add card to cargoCardDeck
                cards.append(card)
            }
            for _ in 1...2 {
                let specialCard = CargoCard(id: UUID(), colour: color, specialPower: true, tonnage: Int.random(in: 1...5), coins: Int.random(in: 1...5))
                // Add specialCard to cargoCardDeck
                cards.append(specialCard)
            }
        }  

        // Shuffle the cards
        let shuffledCards = cards.shuffled()
        print("Prepared and shuffled \(shuffledCards.count) cargo cards.")  
    }
    private func prepareCargoMarketplace() {
        // Draw 5 cards from the cargo card deck to form the marketplace
    }

    private func prepareShips() -> [Ship] {
        // Create 18 ships with varying capacities, tonnage, time cubes, destinations
        // Shuffle the ships
        let ships: [Ship] = [
            Ship(id: 1, cardCapacity: 4, tonnage: 10, timeCubesInitial: 3, timeCubes: 3, balanceIndicator: 0, tolerance: 1),
            Ship(id: 2, cardCapacity: 5, tonnage: 12, timeCubesInitial: 4, timeCubes: 4, balanceIndicator: 1, tolerance: 1),
            Ship(id: 3, cardCapacity: 6, tonnage: 15, timeCubesInitial: 5, timeCubes: 5, balanceIndicator: -1, tolerance: 2),
            Ship(id: 4, cardCapacity: 7, tonnage: 18, timeCubesInitial: 6, timeCubes: 6, balanceIndicator: 2, tolerance: 2),
            Ship(id: 5, cardCapacity: 8, tonnage: 20, timeCubesInitial: 7, timeCubes: 7, balanceIndicator: -2, tolerance: 3),
            Ship(id: 6, cardCapacity: 9, tonnage: 22, timeCubesInitial: 8, timeCubes: 8, balanceIndicator: 0, tolerance: 2),
            Ship(id: 7, cardCapacity: 10, tonnage: 25, timeCubesInitial: 9, timeCubes: 9, balanceIndicator: 1, tolerance: 3),
            Ship(id: 8, cardCapacity: 11, tonnage: 28, timeCubesInitial: 10, timeCubes: 10, balanceIndicator: -1, tolerance: 4),
            Ship(id: 9, cardCapacity: 12, tonnage: 30, timeCubesInitial: 11, timeCubes: 11, balanceIndicator: 2, tolerance: 4),
            Ship(id: 10, cardCapacity: 13, tonnage: 32, timeCubesInitial: 12, timeCubes: 12, balanceIndicator: -2, tolerance: 5),
            Ship(id: 11, cardCapacity: 14, tonnage: 35, timeCubesInitial: 13, timeCubes: 13, balanceIndicator: 0, tolerance: 3),
            Ship(id: 12, cardCapacity: 15, tonnage: 40, timeCubesInitial: 14, timeCubes: 14, balanceIndicator: 1, tolerance: 5)
        ]

        // Shuffle the ships
        let shuffledShips = ships.shuffled()
        print("Prepared and shuffled \(shuffledShips.count) ships.")
        return shuffledShips
    }
    private func prepareBuildingCards() {
        // Create 12 building cards with varying costs and effects
        // Shuffle the building cards
    }
    private func prepareBuildingCardMarketplace() {
        // Draw 3 building cards from the building card deck to form the marketplace
    }
    private func prepareDocks() {
        // Create 4 docks, with 3 unlocked and 1 locked
    }

}
