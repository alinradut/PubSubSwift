//
//  Synchronized.swift
//  SimpleEventBus
//
//  Created by Alin Radut on 19/11/2020.
//

import Foundation

@propertyWrapper class Synchronized<T> {
    
    private let semaphore: DispatchSemaphore
    private var value: T
    
    init(wrappedValue: T) {
        self.semaphore = DispatchSemaphore(value: 1)
        self.value = wrappedValue
    }
    
    var wrappedValue: T {
        get {
            semaphore.wait()
            defer { semaphore.signal() }
            return value
        }
        
        set {
            semaphore.wait()
            value = newValue
            semaphore.signal()
        }
    }

    public func synchronized(_ block: ((inout T) -> Void)) {
        semaphore.wait()
        block(&value)
        semaphore.signal()
    }
}
