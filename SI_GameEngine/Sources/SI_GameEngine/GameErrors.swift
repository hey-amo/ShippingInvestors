//
//  GameErrors.swift
//  SI_GameEngine
//
//  Created by Amarjit on 14/10/2025.
//

import Foundation

public protocol GameErrorProtocol: Error, CustomStringConvertible {
    var domain: String { get }          // e.g. "Numeric", "Gameplay", etc.
    var errorDescription: String { get }
}

public enum GameError: GameErrorProtocol, LocalizedError {
    // MARK: - Model / State Errors
    case modelIsNil
    case invalidState(reason: String)
    
    // MARK: - Numeric Errors
    case negativeValue(parameter: String, value: Int)
    case outOfRange(parameter: String, value: Int, min: Int, max: Int)

    // MARK: - Resource Errors
    case notEnoughCoins(required: Int, available: Int)
    
    // MARK: - Action Errors
    case invalidAction(name: String, reason: String)
    
    // MARK: - Fallback
    case unknown
        
    public var domain: String {
        switch self {
        case .modelIsNil, .invalidState: return "State"
        case .negativeValue, .outOfRange: return "Numeric"
        case .notEnoughCoins: return "Resource"
        case .invalidAction: return "Gameplay"
        case .unknown: return "General"
        }
    }
    
    public var errorDescription: String {
           switch self {
           case .modelIsNil:
               return "The game model is nil. Initialisation failed."
           case .invalidState(let reason):
               return "The game state is invalid: \(reason)"
           case .negativeValue(let parameter, let value):
               return "Numeric error: \(parameter) cannot be negative (got \(value))."
           case .outOfRange(let parameter, let value, let min, let max):
               return "Numeric error: \(parameter) = \(value) is out of range (\(min)...\(max))."
           case .notEnoughCoins(let required, let available):
               return "Not enough coins: required \(required), available \(available)."
           case .invalidAction(let name, let reason):
               return "Invalid action '\(name)': \(reason)"
           case .unknown:
               return "An unknown error occurred."
           }
       }

    public var description: String { "[\(domain)] \(errorDescription)" }
}
