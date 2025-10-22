//
//  FileManagerTests.swift
//  Shipping-InvestorsTests
//
//  Created by Amarjit on 22/10/2025.
//

import XCTest
@testable import Shipping_Investors

final class FileManagerTests: XCTestCase {

    private func documentsURL(for fileName: String) -> URL {
        let fm = FileManager.default
        return fm.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(fileName)
    }

    private func removeFileIfExists(_ url: URL) {
        let fm = FileManager.default
        if fm.fileExists(atPath: url.path) {
            try? fm.removeItem(at: url)
        }
    }

    func testSavingAndLoadingPreferences() {
        let fileName = "prefs_\(UUID().uuidString).json"
        let fileURL = documentsURL(for: fileName)
        removeFileIfExists(fileURL)

        // initial store should create and save defaults
        let store = SettingsStore(fileName: fileName)
        XCTAssertEqual(store.preferences, Preferences.`default`)

        // change some values (this triggers save in didSet)
        store.setSound(false)
        store.setMusic(false)
        store.setDarkMode(true)

        // create a new store that reads from the same file -> should reflect saved changes
        let reloaded = SettingsStore(fileName: fileName)
        XCTAssertEqual(reloaded.preferences, store.preferences)

        // cleanup
        removeFileIfExists(fileURL)
    }

    func testResetToDefaultsPersists() {
        let fileName = "prefs_\(UUID().uuidString).json"
        let fileURL = documentsURL(for: fileName)
        removeFileIfExists(fileURL)

        let store = SettingsStore(fileName: fileName)
        store.setSound(false)
        XCTAssertNotEqual(store.preferences, Preferences.`default`)

        // reset and ensure it persisted
        store.resetToDefaults()
        let reloaded = SettingsStore(fileName: fileName)
        XCTAssertEqual(reloaded.preferences, Preferences.`default`)

        removeFileIfExists(fileURL)
    }
}


