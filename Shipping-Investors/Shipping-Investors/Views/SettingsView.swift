//
//  SettingsView.swift
//  Shipping-Investors
//
//  Created by Amarjit on 20/10/2025.
//

import SwiftUI

// MARK: - Model

struct Preferences: Codable, Equatable {
    var soundEnabled: Bool
    var musicEnabled: Bool
    var darkModeEnabled: Bool
    // add other toggles here

    static let `default` = Preferences(soundEnabled: true,
                                       musicEnabled: true,
                                       darkModeEnabled: false)

    // helper copy-with methods to "reinit" value-type on changes (keeps immutability semantics)
    func with(sound: Bool? = nil, music: Bool? = nil, darkMode: Bool? = nil) -> Preferences {
        Preferences(soundEnabled: sound ?? self.soundEnabled,
                    musicEnabled: music ?? self.musicEnabled,
                    darkModeEnabled: darkMode ?? self.darkModeEnabled)
    }
}

// MARK: - Persistence / Store

final class SettingsStore: ObservableObject {
    @Published private(set) var preferences: Preferences {
        didSet {
            save(preferences)
        }
    }

    private let fileURL: URL

    init(fileName: String = "preferences.json") {
        // Uses Application Documents directory — bundle is read-only, so persist to app container.
        let fm = FileManager.default
        if let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            fileURL = docs.appendingPathComponent(fileName)
        } else {
            // fallback to temporary directory if documents unavailable
            fileURL = fm.temporaryDirectory.appendingPathComponent(fileName)
        }

        if let loaded = Self.load(from: fileURL) {
            preferences = loaded
        } else {
            preferences = .default
            save(preferences)
        }
    }

    // Public mutators that re-create the Preferences struct (value semantics)
    func setSound(_ on: Bool) {
        preferences = preferences.with(sound: on)
    }

    func setMusic(_ on: Bool) {
        preferences = preferences.with(music: on)
    }

    func setDarkMode(_ on: Bool) {
        preferences = preferences.with(darkMode: on)
    }

    func resetToDefaults() {
        preferences = .default
    }

    // MARK: - Persistence helpers

    private func save(_ prefs: Preferences) {
        do {
            let data = try JSONEncoder().encode(prefs)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // In production, handle errors more robustly (user-facing or telemetry)
            print("Failed to save preferences:", error)
        }
    }

    private static func load(from url: URL) -> Preferences? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Preferences.self, from: data)
        } catch {
            print("Failed to load preferences:", error)
            return nil
        }
    }
}

// MARK: - View

struct SettingsView: View {
    @StateObject private var store = SettingsStore()

    var body: some View {
        VStack {
            HStack {
                Text("Settings")
                    .font(.title)
                Spacer()
                Button {
                    // dismiss action should be wired by the parent when used in a presentation
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()

            Form {
                Section("Game Settings") {
                    Toggle("Sound Effects", isOn: Binding(
                        get: { store.preferences.soundEnabled },
                        set: { store.setSound($0) }
                    ))
                    Toggle("Background Music", isOn: Binding(
                        get: { store.preferences.musicEnabled },
                        set: { store.setMusic($0) }
                    ))
                }

                Section("Display") {
                    Toggle("Dark Mode", isOn: Binding(
                        get: { store.preferences.darkModeEnabled },
                        set: { store.setDarkMode($0) }
                    ))
                }

                Section {
                    Button("Reset to Defaults") {
                        store.resetToDefaults()
                    }
                }
            }
        }
        .cornerRadius(25)
        .padding()
    }
}

#Preview {
    SettingsView()
}
