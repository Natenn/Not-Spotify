//
//  AuthManager.swift
//  Not-Spotify
//
//  Created by Naten on 24.08.24.
//

import Foundation

final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    private init() {}

    public var isAuthorised: Bool {
        UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken) != nil
    }

    func cacheUserDefaults(_ authResponse: AuthResponse) {
        if let refreshToken = authResponse.refresh_token {
            UserDefaults.standard.setValue(refreshToken, forKey: UserDefaultsKeys.refreshToken)
        }
        UserDefaults.standard.setValue(authResponse.access_token, forKey: UserDefaultsKeys.accessToken)
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(authResponse.expires_in)), forKey: UserDefaultsKeys.expirationDate)
    }
}
