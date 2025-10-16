//
//  GameMessage.swift
//  SI_GameEngine
//
//  Created by Amarjit on 14/10/2025.
//

import Foundation
import Combine

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
/// Keeps newest-first ordering, trims oldest messages when capacity exceeded
/// and provides clear() functionality.
/// Uses Combine publisher so any observer can react to new logs.
public final class GameMessageStore: ObservableObject {
    // Published messages — automatically triggers Combine updates
    @Published private(set) public var messages: [GameMessage] = []
    
    public static let maxMessages: Int = 50

    // Combine subject for broadcasting single messages
    public let messagePublisher = PassthroughSubject<GameMessage, Never>()
    
    public init(messages: [GameMessage] = []) {
        // Keep newest-first and trim
        let ordered = messages.sorted { $0.time > $1.time }
        self.messages = Array(ordered.prefix(Self.maxMessages))
    }

    // Add a text message
    public func add(_ text: String, type: GameMessageType = .info) {
        add(GameMessage(message: text, messageType: type))
    }

    // Add a GameMessage instance
    public func add(_ message: GameMessage) {
        messages.insert(message, at: 0) // newest first
        if messages.count > Self.maxMessages {
            messages.removeLast(messages.count - Self.maxMessages)
        }
        messagePublisher.send(message)
    }

    public func clear() {
        messages.removeAll()
    }

    public var newestFirst: [GameMessage] { messages }
    public var count: Int { messages.count }
}
