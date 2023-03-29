//
//  DBManager.swift
//  Movey
//
//  Created by Jaime Jazareno III on 29/3/2023.
//

import RealmSwift

class DBManager {
//MARK: Singleton
    static let sharedInstance = DBManager()
    private myDB: Realm

    //MARK: Init
    private init(){
        do{
            myDB = try Realm()
        }
        catch{
            print("boooom")
        }

    }

    //retrive data from db
    func getTracks() -> Results<Track>{
        let results: Results<Track> = myDB.objects(Track)
        return results
    }

    //write an object in db
    func addDataModelEntry(object: Track){
        try! myDB.write{
            myDB.add(object, update: true)
        }
    }

}
