//
//  ContentView.swift
//  Not-Spotify
//
//  Created by Naten on 21.08.24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        if AuthManager.shared.isAuthorised || viewModel.authDidSucceed {
            TabBarView().task {
                if AuthManager.shared.userId.isEmpty {
                    AuthManager.shared.getUserId()
                }
            }
        } else {
            AuthWebView(viewModel: viewModel).ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
