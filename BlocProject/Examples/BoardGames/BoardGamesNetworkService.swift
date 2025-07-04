//
//  BoardGamesNetworkService.swift
//  BlocProject
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Alamofire

/// A network service for fetching board game data.
class BoardGamesNetworkService {
    
    enum Constants {
        static let baseURL = "https://boardgamegeek.com/xmlapi"
    }

    func fetchBoardGamesCollection(for userId: String) async throws -> [BoardGameModel] {
        // Automatic String to URL conversion, Swift concurrency support, and automatic retry.
        let response = await AF.request("\(Constants.baseURL)/collection/\(userId)", interceptor: .retryPolicy)
                               // Automatic HTTP Basic Auth.
//                               .authenticate(username: "user", password: "pass")
                               // Caching customization.
                               .cacheResponse(using: .cache)
                               // Redirect customization.
                               .redirect(using: .follow)
                               // Validate response code and Content-Type.
                               .validate()
                               // Produce a cURL command for the request.
                               .cURLDescription { description in
                                 print(description)
                               }
                               // Automatic Decodable support with background parsing.
                               .serializingDecodable([BoardGameModel].self)
                               // Await the full response with metrics and a parsed body.
                               .response
        // Detailed response description for easy debugging.
        debugPrint(response)
        return response.value ?? []
    }
}
