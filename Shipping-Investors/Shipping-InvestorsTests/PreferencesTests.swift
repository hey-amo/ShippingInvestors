//
//  PreferencesTests.swift
//  Shipping-InvestorsTests
//
//  Created by Amarjit on 22/10/2025.
//

import XCTest

import XCTest
@testable import Shipping_Investors

final class PreferenceTests: XCTestCase {

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

    func testToggleSound() {
        let fileName = "prefs_business_\(UUID().uuidString).json"
        let fileURL = documentsURL(for: fileName)
        removeFileIfExists(fileURL)

        let store = SettingsStore(fileName: fileName)
        XCTAssertTrue(store.preferences.soundEnabled, "default should have sound enabled")

        store.setSound(false)
        XCTAssertFalse(store.preferences.soundEnabled, "setSound(false) should disable sound")

        store.setSound(true)
        XCTAssertTrue(store.preferences.soundEnabled, "setSound(true) should enable sound")

        removeFileIfExists(fileURL)
    }

    func testToggleMusic() {
        let fileName = "prefs_business_\(UUID().uuidString).json"
        let fileURL = documentsURL(for: fileName)
        removeFileIfExists(fileURL)

        let store = SettingsStore(fileName: fileName)
        XCTAssertTrue(store.preferences.musicEnabled, "default should have music enabled")

        store.setMusic(false)
        XCTAssertFalse(store.preferences.musicEnabled, "setMusic(false) should disable music")

        store.setMusic(true)
        XCTAssertTrue(store.preferences.musicEnabled, "setMusic(true) should enable music")

        removeFileIfExists(fileURL)
    }

    func testToggleDarkMode() {
        let fileName = "prefs_business_\(UUID().uuidString).json"
        let fileURL = documentsURL(for: fileName)
        removeFileIfExists(fileURL)

        let store = SettingsStore(fileName: fileName)
        XCTAssertFalse(store.preferences.darkModeEnabled, "default should have dark mode disabled")

        store.setDarkMode(true)
        XCTAssertTrue(store.preferences.darkModeEnabled, "setDarkMode(true) should enable dark mode")

        store.setDarkMode(false)
        XCTAssertFalse(store.preferences.darkModeEnabled, "setDarkMode(false) should disable dark mode")

        removeFileIfExists(fileURL)
    }

    func testToggleMultipleTogether() {
        let fileName = "prefs_business_\(UUID().uuidString).json"
        let fileURL = documentsURL(for: fileName)
        removeFileIfExists(fileURL)

        let store = SettingsStore(fileName: fileName)

        // change several settings
        store.setSound(false)
        store.setMusic(false)
        store.setDarkMode(true)

        XCTAssertEqual(store.preferences, Preferences(soundEnabled: false, musicEnabled: false, darkModeEnabled: true))

        // revert
        store.resetToDefaults()
        XCTAssertEqual(store.preferences, Preferences.default)

        removeFileIfExists(fileURL)
    }
}
