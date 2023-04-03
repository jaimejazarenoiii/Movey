//
//  Track.swift
//  Movey
//
//  Created by Jaime Jazareno III on 29/3/2023.
//

import RealmSwift

class Track: Object, Codable {
    @Persisted(primaryKey: true) var trackId: Int
    @Persisted var wrapperType: String
    @Persisted var kind: String
    @Persisted var collectionId: Int?
    @Persisted var artistName: String
    @Persisted var collectionName: String?
    @Persisted var trackName: String
    @Persisted var collectionCensoredName: String?
    @Persisted var trackCensoredName: String
    @Persisted var collectionArtistId: Int?
    @Persisted var isFavorite: Bool? = false
    @Persisted var collectionPrice: Double?
    @Persisted var trackPrice: Double?
    @Persisted var trackRentalPrice: Double?
    @Persisted var collectionHdPrice: Double?
    @Persisted var trackHdPrice: Double?
    @Persisted var trackHdRentalPrice: Double?
    @Persisted var currency: String
    @Persisted var shortDescription: String?
    @Persisted var primaryGenreName: String
    @Persisted var longDescription: String?
    @Persisted var artworkUrl100: String
}
