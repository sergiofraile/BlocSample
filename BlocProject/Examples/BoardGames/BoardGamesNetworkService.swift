//
//  BoardGamesNetworkService.swift
//  BlocProject
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Alamofire
import Foundation

/// A network service for fetching board game data.
// TODO: Try creating an actor for network services instead of a class
class BoardGamesNetworkService {
    
    enum Constants {
        static let baseURL = "https://boardgamegeek.com/xmlapi"
    }

//    func fetchBoardGamesCollection2(for userId: String) async -> [BoardGameModel] {
//        // Automatic String to URL conversion, Swift concurrency support, and automatic retry.
//        let response = await AF.request("\(Constants.baseURL)/collection/\(userId)", interceptor: .retryPolicy)
//                               // Automatic HTTP Basic Auth.
////                               .authenticate(username: "user", password: "pass")
//                               // Caching customization.
//                               .cacheResponse(using: .cache)
//                               // Redirect customization.
//                               .redirect(using: .follow)
//                               // Validate response code and Content-Type.
//                               .validate()
//                               // Produce a cURL command for the request.
//                               .cURLDescription { description in
//                                 print(description)
//                               }
//                               // Automatic Decodable support with background parsing.
//                               .serializingDecodable([BoardGameModel].self)
//                               // Await the full response with metrics and a parsed body.
//                               .response
//        // Detailed response description for easy debugging.
//        debugPrint(response)
//        return response.value ?? []
//    }
    
    
    func fetchDriversChampionship() async {
        let url = "https://f1api.dev/api/current/drivers-championship"
        AF.request(url).response { response in
            debugPrint(response)
        }
    }
    
//    func otherFetch() {
//        let urlString = "https://www.boardgamegeek.com/xmlapi2/collection?username=fray88&stats=1"
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//            guard let data = data else {
//                print("No data returned")
//                return
//            }
//            // The BGG API returns XML—handle as String or parse as needed
//            if let xmlString = String(data: data, encoding: .utf8) {
//                print("Response XML: \(xmlString)")
//            } else {
//                print("Unable to convert data to String")
//            }
//        }
//
//        task.resume()
//    }
    
    
//    func fetchBoardGameCollection() async throws -> String {
//        let urlString = "https://www.boardgamegeek.com/xmlapi2/collection?username=fray88&stats=1"
//        guard let url = URL(string: urlString) else {
//            throw URLError(.badURL)
//        }
//        
//        // Use URLSession.shared.data(from:) async method
//        let (data, _) = try await URLSession.shared.data(from: url)
//        
//        // Convert data to String since response is XML
//        guard let xmlString = String(data: data, encoding: .utf8) else {
//            throw NSError(domain: "InvalidData", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to decode XML as UTF8 string"])
//        }
//        
//        return xmlString
//    }
}
