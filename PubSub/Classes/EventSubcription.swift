//
//  EventSubcription.swift
//  SimpleEventBus
//
//  Created by Alin Radut on 4/2/21.
//

import Foundation

protocol EventSubcription {
    var observer: AnyObject? { get }
    var queue: Queue? { get }
    var receipt: Receipt? { get }
    var isValid: Bool { get }

    func isEqual(to: EventSubcription) -> Bool
    func handle(event: Any)
    func canHandle<T: EventType>(event: T.Type) -> Bool

}
