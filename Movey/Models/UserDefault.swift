//
//  UserDefault.swift
//  Movey
//
//  Created by Jaime Jazareno III on 5/4/2023.
//

import Foundation

@propertyWrapper
struct UserDefault<T: Codable> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {

            if let data = UserDefaults.standard.object(forKey: key) as? Data,
               let user = try? JSONDecoder().decode(T.self, from: data) {
                return user

            } else {
                print("ZXCZCX mLAIAIA")
            }

            return  defaultValue
        }
        set {
            let encoded = try! JSONEncoder().encode(newValue)
            UserDefaults.standard.set(encoded, forKey: key)

        }
    }
}
