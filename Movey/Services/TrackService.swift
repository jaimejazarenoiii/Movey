//
//  TrackService.swift
//  Movey
//
//  Created by Jaime Jazareno IV on 4/1/23.
//

import Foundation
// MARK: Protocol
protocol TrackServiceable {
    func fetchAllTrack() async throws -> [Track]
}

// MARK: Implementation
class TrackService: TrackServiceable {
    /// Fetches all tracks from itunes then save it in DB
    func fetchAllTrack() async throws -> [Track] {
        do {
            let url = URL(string: "https://itunes.apple.com/search?term=star&country=au&media=movie&;all")!
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NetworkError.invalidResponse(message: "Invalid response code.")
            }

            do {
                let responseData = try JSONDecoder().decode(TrackResponse.self,
                                                            from: data)

                DispatchQueue.main.async {
                    DBManager.shared.refresh(tracks: responseData.results)
                }
                return responseData.results
            } catch(let err) {
                throw err
            }
        } catch(let err) {
            throw err
        }
    }
}
