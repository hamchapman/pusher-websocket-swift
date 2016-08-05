//
//  ViewController.swift
//  iOS Example
//
//  Created by Hamilton Chapman on 24/02/2015.
//  Copyright (c) 2015 Pusher. All rights reserved.
//

import UIKit
import PusherSwift

class ViewController: UIViewController, ConnectionStateChangeDelegate {
    var pusher: Pusher! = nil

    @IBOutlet weak var dataTextView: UITextView!

    @IBAction func connectButton(sender: AnyObject) {
        pusher.connect()
    }

    @IBAction func disconnectButton(sender: AnyObject) {
        pusher.disconnect()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let pusherClientOptions = PusherClientOptions(
            authMethod: .Internal(secret: "9239025f4de0ce11c152"),
            host: .Host("192.168.5.49"),
            port: 8300,
            encrypted: false
        )
        pusher = Pusher(key: "d44f5137e214349f7217", options: pusherClientOptions)

        let debugLogger = { (text: String) in debugPrint(text) }
        pusher.connection.debugLogger = debugLogger
        pusher.connection.stateChangeDelegate = self
        pusher.connect()

        let puppyStore = pusher.liveStore("puppies")
        puppyStore.sync({ data in
            if let data = data {
                dispatch_async(dispatch_get_main_queue()) {
                    self.dataTextView.text = self.JSONStringify(data)
                }
            }
        })
    }

    func JSONStringify(value: AnyObject) -> String {
        if NSJSONSerialization.isValidJSONObject(value) {
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(value, options: [])
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string as String
                }
            } catch _ {
            }
        }
        return ""
    }

    func connectionChange(old: ConnectionState, new: ConnectionState) {
        // print the old and new connection states
        print("old: \(old) -> new: \(new)")
    }
}

