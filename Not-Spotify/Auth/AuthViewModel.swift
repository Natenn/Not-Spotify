//
//  AuthViewModel.swift
//  Not-Spotify
//
//  Created by Naten on 21.08.24.
//

import Foundation
import SwiftNetwork

final class AuthViewModel: ObservableObject {
    @Published var authDidSucceed: Bool = false

    func getAuthorizationURL() -> URLRequest? {
        Request(
            baseUrl: BaseUrl.authBaseUrl,
            version: nil,
            endpoint: Endpoint.authorize,
            query: [
                APIKeys.clientId: APICredentials.clientId,
                APIKeys.responseType: APIKeys.code,
                APIKeys.redirectUri: APIConstants.redirectUri,
                APIKeys.showDialog: true,
                APIKeys.scope: UserScopes.getAllUserScopes(),
            ]
        ).urlRequest
    }

    func getCode(from url: URL?) -> String? {
        guard let url else {
            return nil
        }
        let urlComponents = URLComponents(string: url.absoluteString)
        guard let code = urlComponents?.queryItems?.first(where: { $0.name == "code" })?.value else {
            return nil
        }

        return code
    }

    func getAuthToken(from code: String) {
        let request = Request(
            baseUrl: BaseUrl.authBaseUrl,
            version: nil,
            endpoint: Endpoint.authToken,
            method: .post,
            headers: [
                APIKeys.authorization: AuthManager.shared.encodedCredentials,
                APIKeys.contentType: APIConstants.contentType,
            ],
            query: [
                APIKeys.grantType: APIKeys.authorizationCode,
                APIKeys.code: code,
                APIKeys.redirectUri: APIConstants.redirectUri,
            ]
        )

        Task {
            try await SwiftNetwork().execute(request, expecting: AuthResponse.self, success: { response in
                DispatchQueue.main.async {
                    AuthManager.shared.isAuthorised = true
                    AuthManager.shared.cacheUserDefaults(response)
                    Network.shared.configureDefaultRequest()
                }
            })
        }
    }
}
