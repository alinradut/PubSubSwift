import Foundation

public protocol EventType: Equatable {}

public class Receipt: Equatable {
    let id: UUID = .init()

    public static func == (lhs: Receipt, rhs: Receipt) -> Bool {
        return lhs.id == rhs.id
    }
}

/// PubSub implementation.
public class PubSub {

    /// Singleton instance
    public static let shared: PubSub = .init()

    @Synchronized private var observations = [EventSubcription]()

    public init() {}

    /// Subscribe to events. This subscription will remain active until the observer deallocates or until
    /// `unsubscribe()` or `unsubscribe(with: receipt)` is called.
    /// - Parameters:
    ///   - observer: A class based observer.
    ///   - queue: (optional) Queue on which to receive the updates. If nil, it will be the queue where the event
    ///   was posted from.
    ///   - block: Block to execute when the event is posted.
    /// - Returns: Receipt that can be used to cancel this subscription.
    @discardableResult
    public func subscribe<T: EventType>(
        _ observer: AnyObject,
        queue: Queue? = nil,
        block: @escaping (T) -> ()) -> Receipt {
        
        let (observation, receipt) = Subscription.create(observer: observer, queue: queue, block: block)
        _observations.synchronized {
            $0 = $0.filter { !$0.isEqual(to: observation) && $0.isValid }
            $0.append(observation)
        }
        return receipt
    }

    /// Subscribe to events. This subscription will remain active until the receipt is deallocated.
    /// - Parameters:
    ///   - queue: (optional) Queue on which to receive the updates. If nil, it will be the queue where the event
    ///   was posted from.
    ///   - block: Block to execute when the event is posted.
    /// - Returns: Receipt that can be used to cancel this subscription.
    public func subscribe<T: EventType>(queue: Queue? = nil, block: @escaping (T) -> ()) -> Receipt {
        let (observation, receipt) = Subscription.create(observer: nil, queue: queue, block: block)
        _observations.synchronized {
            $0 = $0.filter { $0.isValid }
            $0.append(observation)
        }
        return receipt
    }

    /// Whether we have an active subscription for a given observer.
    /// - Parameter observer: Observer
    /// - Returns: Bool
    public func isSubscribed(_ observer: AnyObject) -> Bool {
        return observations.contains(where: { $0.observer?.isEqual(observer) == true })
    }

    /// Remove an observer, regardless of subscribed events.
    /// - Parameter observer: Observer
    public func unsubscribe(_ observer: AnyObject) {
        observations = observations.filter { $0.observer !== observer && $0.isValid }
    }

    /// Remove an observer for a given event type.
    /// - Parameters:
    ///   - observer: Observer
    ///   - eventType: Event type
    public func unsubscribe<T: EventType>(_ observer: AnyObject, eventType: T.Type) {
        observations = observations.filter {
            if $0.observer !== observer && $0.isValid {
                return true
            }
            return !$0.canHandle(event: eventType)
        }
    }

    /// Remove a subscription based on the receipt
    /// - Parameter receipt: Receipt
    public func unsubscribe(with receipt: Receipt) {
        observations = observations.filter {
            return $0.receipt != receipt && $0.isValid
        }
    }

    /// Post an event.
    /// - Parameter event: Event
    public func post<T: EventType>(_ event: T) {
        observations.forEach {
            guard $0.isValid else {
                return
            }
            $0.handle(event: event)
        }
    }
    
    /// Remove observation with deallocated owners
    private func gc() {
        observations = observations.filter { $0.isValid } // Remove nil observers
    }
}
