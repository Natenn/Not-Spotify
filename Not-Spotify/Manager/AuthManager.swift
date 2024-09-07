//
//  AuthManager.swift
//  Not-Spotify
//
//  Created by Naten on 24.08.24.
//

import Foundation
import SwiftNetwork

final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    private init() {}

    public var isAuthorised: Bool {
        UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken) != nil
    }

    public var shouldRefreshToken: Bool {
        guard let expirationDate else {
            return false
        }

        let currentDate = Date()
        let timeBuffer: TimeInterval = 600

        return currentDate.addingTimeInterval(timeBuffer) >= expirationDate
    }

    private var expirationDate: Date? {
        return UserDefaults.standard.object(forKey: UserDefaultsKeys.expirationDate) as? Date
    }

    private var refreshToken: String {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.refreshToken) ?? ""
    }

    var accessToken: String {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken) ?? ""
    }

    var encodedCredentials: String {
        let credentials = "\(APICredentials.clientId):\(APICredentials.clientSecret)"
        let data = credentials.data(using: .utf8)
        let baseString = data?.base64EncodedString() ?? ""

        return "Basic \(baseString)"
    }

    func cacheUserDefaults(_ authResponse: AuthResponse) {
        if let refreshToken = authResponse.refresh_token {
            UserDefaults.standard.setValue(refreshToken, forKey: UserDefaultsKeys.refreshToken)
        }
        UserDefaults.standard.setValue(authResponse.access_token, forKey: UserDefaultsKeys.accessToken)
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(authResponse.expires_in)), forKey: UserDefaultsKeys.expirationDate)
    }

    func updateToken() {
        let group = DispatchGroup()

        group.enter()

        let request = Request(
            baseUrl: BaseUrl.authBaseUrl,
            version: nil,
            endpoint: Endpoint.authToken,
            method: .post,
            headers: [
                APIKeys.authorization: encodedCredentials,
                APIKeys.contentType: APIConstants.contentType,
            ],
            query: [
                APIKeys.grantType: APIKeys.refreshToken,
                APIKeys.refreshToken: refreshToken,
            ]
        )

        Task {
            try await SwiftNetwork.shared.execute(request, expecting: AuthResponse.self, success: { [weak self] response in
                self?.cacheUserDefaults(response)
                Network.shared.configureDefaultRequest()

                group.leave()
            })
        }

        group.wait()
    }
}
