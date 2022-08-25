import Foundation
import SwiftUI

struct DA: Codable {
    let da: [Da]?

    enum CodingKeys: String, CodingKey {
        case da = "DA"
    }
}

struct Da: Codable {
    let i, v: String
    let t, q: Int
}

struct OpcServers: Codable {
    let da, ae: Int?

    enum CodingKeys: String, CodingKey {
        case da = "DA"
        case ae = "AE"
    }
}

struct Browse: Codable {
    let n, i: String
    let b: Int
}

class myDelegate: NSObject, URLSessionWebSocketDelegate {
}

class WebSocketController : ObservableObject {
    @Published var alertWrapper : [AlertWrapper]
    
    private var session: URLSession
    var socket: URLSessionWebSocketTask!
    
    init(alertWrapper : [AlertWrapper]){
        self.alertWrapper = alertWrapper
        
        self.session = URLSession(configuration: .default, delegate:myDelegate(), delegateQueue: OperationQueue())
        self.connect()
        
    }
    
    func disconnect() {
        self.socket.cancel(with: .normalClosure, reason: nil) 
    }
    
    func connect() {
        // modify opcServer name to yours
        self.socket = session.webSocketTask(with: URL(string: "ws://opcServer/OPC/main.opc")!)
        self.listen()
        self.socket.resume()
        alertWrapper.removeAll()
        
        self.socket.send(.string("browse"), completionHandler: { error in
            if let error = error {
                print("Failed with Error \(error.localizedDescription)")
            } else {
                sleep(1)
                self.socket.send(.string("subscribe:Random.Int1")){_ in }
            }
        })
    }
    
    func listen() {
        
        self.socket.receive { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let message):
                switch message {
                case .string(let str):
                    let jsonData = str.data(using: .utf8)!
                    if str.starts(with: "[{\"D"){
                        let servers = try! JSONDecoder().decode([OpcServers].self, from: jsonData)
                        let da = servers[0].da
                        let ae = servers[1].ae

                        DispatchQueue.main.async {
                            self.alertWrapper.append(AlertWrapper(alert:DA(da: nil), servers: OpcServers(da: da, ae: ae), browseResult: nil))
                        }
                    } else if str.starts(with: "[{\"n"){
                        let browse = try! JSONDecoder().decode([Browse].self, from: jsonData)

                        DispatchQueue.main.async {
                            self.alertWrapper.append(AlertWrapper(alert:DA(da: nil), servers: OpcServers(da: nil, ae: nil), browseResult: browse))
                        }
                    } else if str.starts(with: "{\"D"){
                        let da = try! JSONDecoder().decode(DA.self, from: jsonData)

                        DispatchQueue.main.async {
                            self.alertWrapper.append(AlertWrapper(alert:da, servers: OpcServers(da: nil, ae: nil), browseResult: nil))
                        }
                    }
                    
                    print(str)
                    
                   break
                case .data(_):
                    break
                @unknown default:
                    break
                }
            }
            self.listen()
        }
    }
}
