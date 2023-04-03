//
//  NetworkError.swift
//  Movey
//
//  Created by Jaime Jazareno IV on 4/1/23.
//

import Foundation

enum NetworkError: Error {
    case invalidResponse(message: String)
}
