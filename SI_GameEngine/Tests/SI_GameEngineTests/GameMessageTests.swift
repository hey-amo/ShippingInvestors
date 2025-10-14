//
//  GameMessageTests.swift
//  SI_GameEngine
//
//  Created by Amarjit on 14/10/2025.
//

import XCTest

@testable import SI_GameEngine

final class GameMessageTests: XCTestCase {
    
    var messageStore: GameMessageStore?
    
    override func setUpWithError() throws {
        // Setup
        self.messageStore = GameMessageStore()
    }

    override func tearDownWithError() throws {
        // Teardown
        self.messageStore = nil
    }
    
    func testAddMessage() throws {
        
    }
    
    func testClearMessages() throws {
        
    }
}
