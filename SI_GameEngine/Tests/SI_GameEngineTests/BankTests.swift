//
//  BankTests.swift
//  SI_GameEngine
//
//  Created by Amarjit on 14/10/2025.
//

import XCTest
@testable import SI_GameEngine

final class BankTests: XCTestCase {
    func testCreditNegative_Fails() throws {
        let negativeAmount = -100
        let bank = Bank()
        XCTAssertFalse( bank.canCredit(amount: negativeAmount) )
    }
    func testDebitNegative_Fails() throws {
        let negativeAmount = -100
        let bank = Bank()
        XCTAssertFalse( bank.canDebit(amount: negativeAmount) )
    }
    func testDebitMoreThanBalance_Fails() throws {
        let balance = 100
        let debit = 101
        let bank = Bank(balance: balance)
        XCTAssertFalse( bank.canDebit(amount: debit) )
    }
    
    func testCredit_Succeeds() throws {
        var balance: Int = 0
        var bank = Bank(balance: balance)
        let credit = 1
        balance = bank.credit(amount: credit)
        XCTAssertEqual(balance, credit)
    }
    func testDebit_Succeeds() throws {
        var balance: Int = 10
        var bank = Bank(balance: balance)
        let debit = 1
        let expected = 9
        balance = bank.debit(amount: debit)
        XCTAssertEqual(balance, expected)
    }
}
