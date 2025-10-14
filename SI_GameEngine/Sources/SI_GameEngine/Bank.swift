//
//  Bank.swift
//  SI_GameEngine
//
//  Created by Amarjit on 14/10/2025.
//


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
