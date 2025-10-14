//
//  GameMessageType.swift
//  SI_GameEngine
//
//  Created by Amarjit on 14/10/2025.
//

import Foundation

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
