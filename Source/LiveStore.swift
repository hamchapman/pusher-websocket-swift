//
//  LiveStore.swift
//  PusherSwift
//
//  Created by Hamilton Chapman on 05/08/2016.
//
//

import Foundation

public class LiveStore {
    public let name: String
    public let pusher: Pusher

    public init(name: String, pusher: Pusher) {
        self.name = name
        self.pusher = pusher
        pusher.connect()
    }

    public func sync(callback: (AnyObject?) -> Void) {
        let channel = pusher.subscribe("live-store---\(name)")
        channel.bind("change", callback: callback)

        let request = NSMutableURLRequest(URL: NSURL(string: "https://yolo.ngrok.io/\(pusher.connection.key)/\(name)")!)
        request.HTTPMethod = "GET"

        let urlSession = NSURLSession.sharedSession()

        urlSession.dataTaskWithRequest(request, completionHandler: { data, response, error in
            if let error = error {
                print("Error fetching initial state \(error)")
            }
            if let httpResponse = response as? NSHTTPURLResponse where (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    callback(json)
                } catch {
                    print("Error getting JSON from data: \(data)")
                }
            } else {
                print("Error with response: \(response)")
            }
        }).resume()
    }
}
