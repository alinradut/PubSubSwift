//
//  ViewController.swift
//  PubSub
//
//  Created by Alin Radut on 04/23/2021.
//  Copyright (c) 2021 Alin Radut. All rights reserved.
//

import UIKit
import PubSubSwift

enum Reachability: String, EventType {
    case notReachable
    case reachableOnWifi
    case reachableOnCellular
}

struct Foo {
    var receipt: Receipt?

    init() {
        receipt = PubSub.shared.subscribe(block: { (event: Reachability) in
            print("foo: \(event)")
        })
    }
}

class ViewController: UIViewController {

    var foo: Foo? = Foo()

    override func viewDidLoad() {
        super.viewDidLoad()

        PubSub.shared.subscribe(self, block: { (event: Reachability) in
            print("bar: \(event)")
        })

        print("Posting notReachable")
        // Do any additional setup after loading the view, typically from a nib.
        PubSub.shared.publish(Reachability.notReachable)

        print("Removing foo")
        foo = nil

        print("Posting reachableOnWifi")
        PubSub.shared.publish(Reachability.reachableOnWifi)

        print("Removing bar")
        PubSub.shared.unsubscribe(self)

        // will not be received by anyone
        print("Posting reachableOnCellular")
        PubSub.shared.publish(Reachability.reachableOnCellular)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

