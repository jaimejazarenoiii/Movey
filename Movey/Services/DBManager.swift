//
//  DBManager.swift
//  Movey
//
//  Created by Jaime Jazareno III on 29/3/2023.
//

import RealmSwift

class DBManager {
    // MARK: Singleton
    static let shared = DBManager()
    static let thread = DispatchQueue(label: "realm-queue")
    private var realm: Realm?

    // MARK: Init
    private init(){
        do{
            realm = try Realm()
        }
        catch{
            print("boooom")
        }
    }

    /// retrive all tracks from db
    func getTracks() -> [Track] {
        let results: Results<Track> = realm!.objects(Track.self)
        return results.map { $0 }
    }

    /// retrieve one track from db
    func getTrack(id: Int) -> Track? {
        return realm!.objects(Track.self).first(where: { $0.trackId == id })
    }

    /// Purge tracks and set new entry
    func refresh(tracks: [Track]) {
        let results: Results<Track> = realm!.objects(Track.self)
        guard results.isEmpty else { return }
        try! self.realm!.write {
            self.realm!.add(tracks, update: .all)
        }
    }

    /// write an object in db
    func addDataModelEntry(object: Track){
        try! realm!.write{
            realm!.add(object)
        }
    }

    /// Update track in db
    func update(track: Track, isFavorite: Bool) {
        try! realm!.write {
            track.isFavorite = isFavorite
            realm!.add(track, update: .all)
        }
    }

}
