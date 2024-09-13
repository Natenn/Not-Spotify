//
//  SettingsView.swift
//  Not-Spotify
//
//  Created by Naten on 13.09.24.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel.shared
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    themePicker
                    languagePicker
                }
                Button("Log out") {
                    showAlert = true
                }
                .alert(isPresented: $showAlert) {
                    logoutAlert
                }
                .tint(.pink)
            }
            .padding(.top, Constants.padding)
            .navigationTitle("Settings")
        }
    }

    private var themePicker: some View {
        Picker(selection: $viewModel.colourScheme) {
            ForEach(viewModel.colourSchemes) { item in
                Text(item.title).tag(item.id)
            }
        } label: {
            Text("Colour Scheme")
        }
    }

    private var languagePicker: some View {
        Picker(selection: $viewModel.locale) {
            ForEach(viewModel.languages) { item in
                Text(item.title).tag(item.id)
            }
        } label: {
            Text("Language")
        }
    }

    private var logoutAlert: Alert {
        Alert(
            title: Text("Log Out"),
            message: Text("Are you sure you want to log out?"),
            primaryButton: .default(
                Text("Cancel"),
                action: {}
            ),
            secondaryButton: .destructive(
                Text("Leave"),
                action: {
                    AuthManager.shared.clearCache()
                }
            )
        )
    }
}

#Preview {
    SettingsView()
}
