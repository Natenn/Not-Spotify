//
//  Network.swift
//  Not-Spotify
//
//  Created by Naten on 25.08.24.
//

import Combine
import Foundation
import SwiftNetwork

final class Network {
    public static let shared = Network()

    private init() {}

    func execute<T: Decodable>(_ request: Request, expecting type: T.Type) -> Future<T, Error> {
        if AuthManager.shared.shouldRefreshToken, !AuthManager.shared.isRefreshingToken {
            AuthManager.shared.updateToken()
        }

        return SwiftNetwork.shared.execute(request, expecting: type)
    }

    func configureDefaultRequest() {
        Config.main.baseUrl = BaseUrl.spotifyApiBaseUrl
        Config.main.version = .v1
        Config.main.needsAuthToken = true
        Config.main.authToken = "Bearer \(AuthManager.shared.accessToken)"
    }
}
