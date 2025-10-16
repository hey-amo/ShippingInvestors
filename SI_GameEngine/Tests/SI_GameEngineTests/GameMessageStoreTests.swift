//
//  GameMessageStoreTests.swift
//  SI_GameEngine
//
//  Created by Amarjit on 16/10/2025.
//


import XCTest
import Combine
@testable import SI_GameEngine

final class GameMessageStoreTests: XCTestCase {
    private var store: GameMessageStore!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        store = GameMessageStore()
        cancellables = []
    }

    override func tearDown() {
        store = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testAddingMessage() {
        let expectation = XCTestExpectation(description: "Message publisher should make new message")

        store.messagePublisher
            .sink { msg in
                XCTAssertEqual(msg.message, "Test Message")
                XCTAssertEqual(msg.messageType, .info)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        store.add("Test Message", type: .info)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(store.count, 1)
        XCTAssertEqual(store.newestFirst.first?.message, "Test Message")
    }
    
    func testClearMessages() {
        store.add("Msg 1")
        store.add("Msg 2")

        XCTAssertEqual(store.count, 2)
        store.clear()
        XCTAssertTrue(store.newestFirst.isEmpty)
    }
    
    func testStopObserver() {
        var receivedCount = 0
        let cancellable = store.messagePublisher
            .sink { _ in receivedCount += 1 }

        store.add("Before cancel")
        XCTAssertEqual(receivedCount, 1)

        cancellable.cancel()
        store.add("After cancel")
        XCTAssertEqual(receivedCount, 1, "No message should be received after cancel")
    }
    
    func testMemoryLeakOnStoreDeinit() {
        weak var weakStore: GameMessageStore?

        autoreleasepool {
            var store: GameMessageStore? = GameMessageStore()
            weakStore = store
            store?.add("Leak check")
            store = nil
        }

        XCTAssertNil(weakStore, "GameMessageStore should have been deallocated")
    }
    
    func testObserverDeallocation() {
        var cancellable: AnyCancellable? = store.messagePublisher.sink { _ in }
        weak var weakCancellable = cancellable as AnyObject?

        cancellable = nil
        XCTAssertNil(weakCancellable, "Combine subscription should deallocate")
    }


}
