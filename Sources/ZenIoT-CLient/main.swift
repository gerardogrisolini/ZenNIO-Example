//
//  main.swift
//  ZenIot-Client
//
//  Created by Gerardo Grisolini on 21/11/20.
//

import Foundation
import NIO
import ZenIoT


let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

let host: String = "squid.rmq.cloudamqp.com"
let username: String = "tmhtseai:tmhtseai"
let password: String = "Elpycwnwdx5ZZoxMvP49kcSNmG8zl3q9"


/// Device

let device = DeviceModel(macAddress: getMacAddress() ?? "unknown")
device.name = "uname".shell(arguments: ["-a"])!
device.system = "cat".shell(arguments: ["/etc/os-release"])!
device.version = "1.0.0"


/// MQTT

let service = MqttService(host: host, username: username, password: password, eventLoopGroup: eventLoopGroup)
service.onMessageReceived = { message in
    print(message.stringRepresentation!)
    
    if let action = try? JSONDecoder().decode(DeviceAction.self, from: message.payload) {
        print("💬 Method: \(action.method)")
        switch action.method {
        case "reboot":
            break
        default:
            break
        }
    }
}

defer {
    try? service.unsubscribe(topic: "raspberry.\(device.macAddress)").wait()
    try? service.disconnect().wait()
    try? eventLoopGroup.syncShutdownGracefully()
}

try service.connect().wait()
try service.subscribe(topic: "raspberry.\(device.macAddress)", qos: .atLeastOnce).wait()


/// TimeZone

getTimezone { deviceInfo in
    guard let deviceInfo = deviceInfo else { return }
    
    setTimezone(deviceInfo.timezone)
    device.info = deviceInfo
    try! service.publish(topic: "raspberry", payload: device).wait()
}

sleep(30)


/// Helpers

func get<T: Decodable>(_ type: T.Type, url: String,  headers: [String:String], completion: @escaping ((T?) -> (Void))) {
    guard let url = URL(string: url) else { return }
    
    var request = URLRequest(url: url)
    request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
    request.allHTTPHeaderFields = headers
    request.httpMethod = "GET"

    URLSession.shared.dataTask(with: request) { (data, response, error) in
        
        if let error = error {
            print("🔴 \(error)")
            completion(nil)
            return
        }
        
        guard let data = data else {
            print("🔴 No data received")
            completion(nil)
            return
        }
        
        do {
            let item = try JSONDecoder().decode(type.self, from: data)
            completion(item)
        }
        catch let jsonErr {
            print("🔴 \(jsonErr)")
            completion(nil)
        }

    }.resume()
}

func getTimezone(completion: @escaping ((DeviceInfo?) -> (Void))) {
    var headers = [String:String]()
    headers["Content-Type"] = "application/json"
    
    get(DeviceInfo.self, url: "http://ip-api.com/json", headers: headers) { info -> (Void) in
        if let info = info {
            completion(info)
        } else {
            completion(nil)
        }
    }
}

func setTimezone(_ tz: String) {
    if let timeZone = TimeZone(identifier: tz) {
        print("⏱️ Timezone: \(tz) -> \(timeZone)")
#if os(Linux)
        _ = "timedatectl".shell(arguments: ["set-timezone", tz])
#endif
    }
}

func getMacAddress() -> String? {
    #if os(Linux)
    let cardName = "wlan0"
    #else
    let cardName = "en0"
    #endif
    if let response = "ifconfig".shell(arguments: [cardName]), let range = response.range(of: "ether") {
        let index = response.index(range.upperBound, offsetBy: 17)
        return response[range.upperBound...index].trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    return nil
}
