//
//  SettingsView.swift
//  Shipping-Investors
//
//  Created by Amarjit on 20/10/2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Settings")
                    .font(.title)
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Form {
                Section("Game Settings") {
                    Toggle("Sound Effects", isOn: .constant(true))
                    Toggle("Background Music", isOn: .constant(true))
                }
                
                Section("Display") {
                    Toggle("Dark Mode", isOn: .constant(false))
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
