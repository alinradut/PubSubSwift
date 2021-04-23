//
//  Queue.swift
//  SimpleEventBus
//
//  Created by Alin Radut on 4/2/21.
//

import Foundation

public enum Queue {
    case main
    case background(queue: DispatchQueue?)

    var queue: DispatchQueue {
        switch self {
        case .main:
            return .main
        case .background(let queue):
            return queue ?? .global()
        }
    }
}
