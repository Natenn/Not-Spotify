//
//  AuthWebView.swift
//  Not-Spotify
//
//  Created by Naten on 21.08.24.
//

import SwiftUI
import WebKit

// MARK: - AuthWebView

struct AuthWebView: UIViewRepresentable {
    @ObservedObject var viewModel: AuthViewModel

    let webView = WKWebView()

    func makeUIView(context _: Context) -> WKWebView {
        webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let authRequest = viewModel.getAuthorizationURL() else {
            return
        }

        webView.navigationDelegate = context.coordinator
        webView.load(authRequest)
    }
}

// MARK: - AuthWebView.Coordinator

extension AuthWebView {
    class Coordinator: NSObject {
        var viewModel: AuthViewModel
        var parent: AuthWebView

        init(_ parent: AuthWebView) {
            self.parent = parent
            viewModel = parent.viewModel
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - AuthWebView.Coordinator + WKNavigationDelegate

extension AuthWebView.Coordinator: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        guard let code = viewModel.getCode(from: webView.url) else {
            return
        }

        viewModel.getAuthToken(from: code)
    }
}
