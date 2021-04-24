// https://github.com/Quick/Quick

import Quick
import Nimble
import PubSubSwift

enum LoginEvent: EventType {
    case Success(Int)
    case Failure
}

struct RegistrationEvent: EventType {}

class Observer {}

class TableOfContentsSpec: QuickSpec {

    private var eventHub: PubSub = PubSub()

    override func spec() {

        describe("an event") {
            var result: Int!
            var observer: Observer?
            var receipt: Receipt?

            context("when the block is run synchronously on the posting thread") {
                beforeEach {
                    result = 0
                    observer = Observer()

                    receipt = self.eventHub.subscribe(observer!) { (event: LoginEvent) in
                        switch event {
                        case .Success(let i):
                            result = result + i
                        case .Failure:
                            break
                        }
                    }
                }
                afterEach {
                    if let observer = observer {
                        self.eventHub.unsubscribe(observer)
                    }
                    receipt = nil
                }

                it("is observed") {
                    self.eventHub.post(LoginEvent.Success(1))
                    expect(result) == 1
                }

                it("is observed multiple times") {
                    self.eventHub.post(LoginEvent.Success(1))
                    self.eventHub.post(LoginEvent.Success(2))
                    self.eventHub.post(LoginEvent.Success(3))
                    expect(result) == 6
                }

                it("isn't observed if observer is deinited") {
                    observer = nil
                    self.eventHub.post(LoginEvent.Success(1))
                    expect(result) == 0
                }

                it("isn't observed if observer is removed") {
                    expect(self.eventHub.isSubscribed(observer!)) == true
                    self.eventHub.unsubscribe(observer!)
                    expect(self.eventHub.isSubscribed(observer!)) == false
                    self.eventHub.post(LoginEvent.Success(1))
                    expect(result) == 0
                }

                it("isn't observed if another event is posted") {
                    self.eventHub.post(RegistrationEvent())
                    expect(result) == 0
                }

                it("produces a receipt") {
                    expect(receipt != nil) == true
                }

                it("isn't observed if observer is removed via receipt") {
                    self.eventHub.unsubscribe(with: receipt!)
                    expect(self.eventHub.isSubscribed(observer!)) == false
                }

                it("is observed only once regardless of the number of subscriptions") {
                    self.eventHub.subscribe(observer!) { (event: LoginEvent) in
                        switch event {
                        case .Success(let i):
                            result = result + i * 1
                        case .Failure:
                            break
                        }
                    }
                    self.eventHub.subscribe(observer!) { (event: LoginEvent) in
                        switch event {
                        case .Success(let i):
                            result = result + i * 5
                        case .Failure:
                            break
                        }
                    }
                    self.eventHub.subscribe(observer!) { (event: LoginEvent) in
                        switch event {
                        case .Success(let i):
                            result = result + i * 10
                        case .Failure:
                            break
                        }
                    }

                    self.eventHub.post(LoginEvent.Success(1))
                    expect(result) == 10
                }

                it("can remove the observation for one event while still receiving another") {
                    self.eventHub.subscribe(observer!) { (event: RegistrationEvent) in
                        result = result + 10
                    }
                    self.eventHub.unsubscribe(observer!, eventType: LoginEvent.self)
                    self.eventHub.post(RegistrationEvent())
                    expect(result) == 10
                }
            }

            context("when no observer is used") {
                beforeEach {
                    result = 0
                    receipt = self.eventHub.subscribe { (event: LoginEvent) in
                        switch event {
                        case .Success(let i):
                            result = result + i
                        case .Failure:
                            break
                        }
                    }
                }
                afterEach {
                    if let receipt = receipt {
                        self.eventHub.unsubscribe(with: receipt)
                    }
                }

                it("is observed") {
                    self.eventHub.post(LoginEvent.Success(1))
                    expect(result) == 1
                }
                
                it("is not observed if receipt deinits") {
                    receipt = nil
                    self.eventHub.post(LoginEvent.Success(1))
                    expect(result) == 0
                }
                
                it("is observed once for each receipt observation") {
                    
                    let receipt2 = self.eventHub.subscribe { (event: LoginEvent) in
                        switch event {
                        case .Success(let i):
                            result = result + i
                        case .Failure:
                            break
                        }
                    }
                    let receipt3 = self.eventHub.subscribe { (event: LoginEvent) in
                        switch event {
                        case .Success(let i):
                            result = result + i
                        case .Failure:
                            break
                        }
                    }
                    
                    self.eventHub.post(LoginEvent.Success(1))
                    expect(result) == 3
                }
            }

            context("when the block is run asynchronously on the main thread") {
                beforeEach {
                    result = 0
                    observer = Observer()

                    self.eventHub.subscribe(observer!, queue: .main) { (event: LoginEvent) in
                        expect(Thread.isMainThread) == true

                        switch event {
                        case .Success(let i):
                            result = result + i
                        case .Failure:
                            break
                        }
                    }
                }
                afterEach {
                    if let observer = observer {
                        self.eventHub.unsubscribe(observer)
                    }
                }

                it("is observed") {
                    self.eventHub.post(LoginEvent.Success(1))
                    expect(result).toEventually(equal(1))
                }
            }

            context("when the block is run asynchronously on the background thread") {
                beforeEach {
                    result = 0
                    observer = Observer()

                    self.eventHub.subscribe(observer!, queue: .background(queue: nil)) { (event: LoginEvent) in
                        expect(Thread.isMainThread) == false

                        switch event {
                        case .Success(let i):
                            result = result + i
                        case .Failure:
                            break
                        }
                    }
                }
                afterEach {
                    if let observer = observer {
                        self.eventHub.unsubscribe(observer)
                    }
                }

                it("is observed") {
                    self.eventHub.post(LoginEvent.Success(1))
                    expect(result).toEventually(equal(1))
                }
            }

            context("when it is posted with other events at the same time") {
                beforeEach {
                    result = 0
                    observer = Observer()

                    self.eventHub.subscribe(observer!, queue: .main) { (event: LoginEvent) in
                        switch event {
                        case .Success(let i):
                            result = result + i
                        case .Failure:
                            break
                        }
                    }
                }
                afterEach {
                    if let observer = observer {
                        self.eventHub.unsubscribe(observer)
                    }
                }

                it("is observed without any crash") {

                    let qosClasses: [DispatchQoS.QoSClass] = [
                        .userInitiated,
                        .userInteractive,
                        .utility,
                        .default
                    ]

                    DispatchQueue.concurrentPerform(iterations: 50_000) { i in
                        let qos: DispatchQoS.QoSClass = qosClasses[Int.random(in: 0..<qosClasses.count)]
                        if Int.random(in: 0..<100) == 0 {
                            DispatchQueue.main.async {
                                // print("\(i) - main")
                                self.eventHub.post(LoginEvent.Success(1))
                            }
                        } else {
                            DispatchQueue.global(qos: qos).async {
                                // print("\(i) - \(qos)")
                                self.eventHub.post(LoginEvent.Success(1))
                            }
                        }
                    }

                    expect(result).toEventually(equal(50_000), timeout: 100, pollInterval: 0.1)
                }
            }

            context("when the observation is overwritten") {
                beforeEach {
                    result = 0
                    observer = Observer()

                    self.eventHub.subscribe(observer!) { (event: LoginEvent) in
                        switch event {
                        case .Success(let i):
                            result = result + i
                        case .Failure:
                            break
                        }
                    }
                }
                afterEach {
                    if let observer = observer {
                        self.eventHub.unsubscribe(observer)
                    }
                }

                it("is overwritten") {
                    self.eventHub.subscribe(observer!) { (event: LoginEvent) in
                        switch event {
                        case .Success(let i):
                            result = result + i * 10
                        case .Failure:
                            break
                        }
                    }

                    self.eventHub.post(LoginEvent.Success(1))
                    expect(result) == 10
                }
            }

            context("when multiple observers observe the same event") {
                let otherObserver = Observer()
                var otherResult: Int = 0

                beforeEach {
                    result = 0
                    observer = Observer()

                    self.eventHub.subscribe(observer!) { (event: LoginEvent) in
                        switch event {
                        case .Success(let i):
                            result = result + i
                        case .Failure:
                            break
                        }
                    }
                }
                afterEach {
                    if let observer = observer {
                        self.eventHub.unsubscribe(observer)
                    }
                }

                it("is added another observer") {
                    self.eventHub.subscribe(otherObserver) { (event: LoginEvent) in
                        switch event {
                        case .Success(let i):
                            otherResult = otherResult + i * 10
                        case .Failure:
                            break
                        }
                    }

                    expect(self.eventHub.isSubscribed(observer!)) == true

                    self.eventHub.post(LoginEvent.Success(1))

                    expect(result) == 1
                    expect(otherResult) == 10
                }
            }

            context("when observer is removed") {
                beforeEach {
                    result = 0
                    observer = Observer()

                    self.eventHub.subscribe(observer!) { (event: LoginEvent) in
                        switch event {
                        case .Success(let i):
                            result = result + i
                        case .Failure:
                            break
                        }
                    }
                }
                afterEach {
                    if let observer = observer {
                        self.eventHub.unsubscribe(observer)
                    }
                }

                it("is added another observer") {

                    expect(self.eventHub.isSubscribed(observer!)) == true
                    self.eventHub.unsubscribe(observer!)
                    expect(self.eventHub.isSubscribed(observer!)) == false
                }
            }
        }
    }
}
