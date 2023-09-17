//
//  NetworkError.swift
//  Movey
//
//  Created by Jaime Jazareno IV on 4/1/23.
//

import Foundation

/**
 Custom error

 values:
 - invalidResponse(message: String):
  - Parameters:
    * message - a string can be passed to identify the error.
 */
enum NetworkError: Error {
    case invalidResponse(message: String)
}
