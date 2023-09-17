//
//  TracksCollectionViewCellData.swift
//  Movey
//
//  Created by Jaime Jazareno IV on 4/3/23.
//

import Foundation

/**
 Cell presentation Data
 */
struct TracksCollectionViewCellData: Hashable {
    let section: Int
    let tracks: [Track]
}
