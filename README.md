# PubSub.swift

[![CI Status](https://img.shields.io/travis/alinradut/PubSub.svg?style=flat)](https://travis-ci.org/alinradut/PubSub)
[![Version](https://img.shields.io/cocoapods/v/PubSub.svg?style=flat)](https://cocoapods.org/pods/PubSub)
[![License](https://img.shields.io/cocoapods/l/PubSub.svg?style=flat)](https://cocoapods.org/pods/PubSub)
[![Platform](https://img.shields.io/cocoapods/p/PubSub.svg?style=flat)](https://cocoapods.org/pods/PubSub)

A type-safe implementation Swift of PubSub/event hub that can be used as a replacement for the NotificationCenter.

## Usage

The easiest way is to just use the singleton instance, but you can always instantiate your own using `PubSub()`:
```
let pubSub = PubSub.shared
// or
let pubSub = PubSub()
```


Events can be defined as needed:

```
enum Reachability: EventType {
    case notReachable
    case reachableOnWifi
    case reachableOnCellular
}

struct ActivationCode: EventType {
    let code: String
}
```
And can be posted as such:

```
pubSub.post(ActivationCode(code: "123456"))
```

### Subscribing to an event with an observer
```

pubSub.subscribe(self) { (event: Reachability) in
    // handle reachability change
}

// remove the Reachability subscription
pubSub.unsubscribe(self, eventType: Reachability.self)

// remove all of our subscriptions
pubSub.unsubscribe(self)

// you can also obtain a receipt when subscribing
let receipt = pubSub.subscribe(self) { (event: Reachability) in
    // handle reachability change
}

// remove the subscription based on the receipt:
pubSub.unsubscribe(with: receipt)
```

### Subscribing to an event using a receipt

Due to the fact that `pubSub.subscribe(_ observer: AnyObject)` requires that the observer is a reference type, we need a different method to keep our subscription alive when we want to use it with value types. Therefore, we can make use of receipts by adding them as a member to the structs you want to become as observers.

Receipts can also be used to explicitly remove subscriptions when they are no longer needed. 

```
struct Foo {
    private var receipt: Receipt

    init() {
        self.receipt = pubSub.subscribe { (event: Reachability) in
            // we will keep receiving events until the receipt is deallocated 
            // or it is used to cancel the subscription
        }
    }
}

```

In this case, the observation will be removed when this Foo instance is deallocated, which in turn deallocates `receipt`.

### Subscribing on a specific queue

You can specify at subscription time the queue you want to receive your event on:

```
pubSub.subscribe(queue: .main) { (event: Reachability) in 
    // ...
}
```

If the receiver is subscribed on the main queue and the message is posted from the main queue, the subscriber will receive it synchronously, otherwise it will be dispatched asynchronously. If no queue is specified, the queue where the message is posted from will be used to deliver it synchronously.


## Requirements

None, there are no dependencies.

## Installation

PubSub is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PubSub.swift'
```

## Author

Alin Radut

Credit where credit's due: this is a reimplementation of https://github.com/mishimay/EventHub.

## License

PubSub is available under the MIT license. See the LICENSE file for more info.
