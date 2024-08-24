//
//  AuthViewModel.swift
//  Not-Spotify
//
//  Created by Naten on 21.08.24.
//

import Combine
import Foundation
import SwiftNetwork

final class AuthViewModel: ObservableObject {
    @Published var authDidSucceed: Bool = false

    private var cancellables = Set<AnyCancellable>()

    func getAuthorizationURL() -> URLRequest? {
        Request(
            baseUrl: BaseUrl.authBaseUrl,
            endpoint: Endpoint.authorize,
            query: [
                APIKeys.clientId: APICredentials.clientId,
                APIKeys.responseType: APIKeys.code,
                APIKeys.redirectUri: Constants.redirectUri,
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
            endpoint: Endpoint.authToken,
            method: .post,
            headers: [
                APIKeys.authorization: getEncodedCredentials(),
                APIKeys.contentType: Constants.contentType,
            ],
            query: [
                APIKeys.grantType: APIKeys.authorizationCode,
                APIKeys.code: code,
                APIKeys.redirectUri: Constants.redirectUri,
            ]
        )

        SwiftNetwork.shared.execute(request, expecting: AuthResponse.self)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.authDidSucceed = true
                    case .failure:
                        break
                    }
                },
                receiveValue: { response in
                    AuthManager.shared.cacheUserDefaults(response)
                }
            ).store(in: &cancellables)
    }

    private func getEncodedCredentials() -> String {
        let credentials = "\(APICredentials.clientId):\(APICredentials.clientSecret)"
        let data = credentials.data(using: .utf8)
        let baseString = data?.base64EncodedString() ?? ""

        return "Basic \(baseString)"
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
