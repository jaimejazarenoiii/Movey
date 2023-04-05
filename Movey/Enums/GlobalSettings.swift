//
//  GlobalSettings.swift
//  Movey
//
//  Created by Jaime Jazareno III on 5/4/2023.
//

import Foundation

enum GlobalSettings {

    @UserDefault("track", defaultValue: Track()) static var track: Track
}
