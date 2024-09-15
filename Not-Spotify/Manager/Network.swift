//
//  Network.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import Foundation
import SwiftNetwork

final class Network: Networkable {
    public static let shared = Network()

    private init() {}

    func execute<T: Decodable>(
        _ request: Request,
        expecting type: T.Type,
        success: @escaping @Sendable (T) -> Void = { _ in },
        failure: @escaping @Sendable (_ error: Error) -> Void = { _ in }
    ) async throws {
        if AuthManager.shared.shouldRefreshToken {
            AuthManager.shared.updateToken()
        }

        try await SwiftNetwork().execute(
            request,
            expecting: type,
            success: success,
            failure: failure
        )
    }

    func configureDefaultRequest() {
        Config.main.baseUrl = BaseUrl.spotifyApiBaseUrl
        Config.main.version = .v1
        Config.main.needsAuthToken = true
        Config.main.authToken = "Bearer \(AuthManager.shared.accessToken)"
    }
}
