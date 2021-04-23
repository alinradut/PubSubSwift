//
//  DispatchQueueOnMain.swift
//  SimpleEventBus
//
//  Original: https://github.com/ReactiveX/RxSwift/blob/53cd723d40d05177e790c8c34c36cec7092a6106/Platform/DispatchQueue%2BExtensions.swift
//
//
//  Created by Alin Radut on 19/11/2020.
//
import Foundation

public extension DispatchQueue {
    
    /// Automatically sets and returns the associated DispatchSpecificKey
    /// that was attached to the main queue.
    private static var token: DispatchSpecificKey<()> = {
        let key = DispatchSpecificKey<()>()
        DispatchQueue.main.setSpecific(key: key, value: ())
        return key
    }()
    
    static var isMain: Bool {
        // check whether there's anything set for the `token` DispatchSpecificKey
        // if true, it means we're on the main queue.
        return DispatchQueue.getSpecific(key: token) != nil
    }
    
    /// Execute the given block on the main queue. If we're already on the main queue,
    /// proceed to execute. If we're not, dispatch asynchronously.
    /// - Parameter block: Block to execute
    static func onMain(_ block: @escaping (() -> Void)) {
        if DispatchQueue.isMain {
            block()
        }
        else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
