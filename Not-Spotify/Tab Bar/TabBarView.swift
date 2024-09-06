//
//  TabBarView.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import Combine
import SwiftUI

// MARK: - TabBarView

struct TabBarView: View, KeyboardReadable {
    @State private var isKeyboardVisible = false

    var body: some View {
        TabView {
            Tab("Library", systemImage: "books.vertical") {
                LibraryView()
            }
            Tab("Search", systemImage: "magnifyingglass") {
                SearchView()
            }
        }
        .onReceive(keyboardPublisher) { isKeyboardVisible in
            self.isKeyboardVisible = isKeyboardVisible
        }
        .safeAreaInset(edge: .bottom) {
            MiniPlayerView()
                .padding([.top, .bottom], Constants.padding)
                .offset(y: offset)
        }
    }
    
    private var offset: CGFloat {
        isKeyboardVisible ? 0 : -UITabBarController().tabBar.frame.size.height
    }
}

// MARK: - KeyboardReadable

protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },

            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}

#Preview {
    TabBarView()
}
