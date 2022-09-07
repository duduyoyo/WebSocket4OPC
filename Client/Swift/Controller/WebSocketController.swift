import Foundation
import SwiftUI

// MARK: - AE
struct AE: Codable {
    let ae: [AEItem]

    enum CodingKeys: String, CodingKey {
        case ae = "AE"
    }
}

struct AEItem: Codable, Identifiable {
    var id : String {s}
    
    let s, m, c, sc: String
    let t, q, tp, ec: Int
    let st, a: Int
    let at: String
    
    enum CodingKeys: String, CodingKey {
        case s, m, c, sc,t, q, tp, ec,st, a,at
    }
}

// MARK: - DA
struct DA: Codable {
    let da: [DAItem]

    enum CodingKeys: String, CodingKey {
        case da = "DA"
    }
}

struct DAItem: Codable, Identifiable {
    var id : String {i}
    
    let i, v: String
    let t, q: Int
    
    enum CodingKeys: String, CodingKey {
        case i,v,t,q
    }
}

// MARK: - Servers
struct OpcServers: Codable {
    var da, ae: Int?

    enum CodingKeys: String, CodingKey {
        case da = "DA"
        case ae = "AE"
    }
}

// MARK: - Browse
struct Browse: Codable, Identifiable {
    var id : String {i}
    
    let n, i: String
    let b: Int
    
    enum CodingKeys: String, CodingKey {
        case i,n,b
    }
}

class myDelegate: NSObject, URLSessionWebSocketDelegate {
}

class WebSocketController : ObservableObject {
    @Published var AEResult : [AEItem]
    @Published var DAResult : [DAItem]
    @Published var browseResult : [Browse]
    @Published var isConnected:Bool
    @Published var isDAsupported:Bool
    @Published var isAEsupported:Bool
    
    private var session: URLSession
    var socket: URLSessionWebSocketTask!
    
    init(DAResult : [DAItem], AEResult : [AEItem], browseResult : [Browse], servers : OpcServers, isConnected:Bool, isDAsupported:Bool, isAEsupported:Bool){
        
        self.DAResult = DAResult
        self.AEResult = AEResult
        self.browseResult = browseResult
        self.isConnected = isConnected
        self.isDAsupported=isDAsupported
        self.isAEsupported=isAEsupported
        self.session = URLSession(configuration: .default, delegate: myDelegate(), delegateQueue: OperationQueue())
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
        DAResult.removeAll()
        AEResult.removeAll()
        
        self.socket.send(.string("browse"), completionHandler: { error in
            if let error = error {
                print("Failed with Error \(error.localizedDescription)")
            } else {
                sleep(1)
                self.socket.send(.string("subscribe:Random.Int1, Random.Int2, Random.Real4, Random.Real8")){_ in }
                sleep(1)
                self.socket.send(.string("subscribeAE")){_ in} }
        })
    }
    
    func listen() {
        
        self.socket.receive { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                if let error = error as NSError? {
                    print(error.localizedDescription)
                    if let value = error.userInfo[NSURLErrorFailingURLErrorKey] as! NSURL? {
                        print(value.absoluteString!)
                        
                        DispatchQueue.main.async {
                            self.isConnected = false
                            self.isDAsupported = false
                            self.isAEsupported = false
                        }
                    }
                }
                self.socket.cancel()
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
                            self.isDAsupported = (da != nil)
                            self.isAEsupported = (ae != nil)
                            
                            if da==1 || ae==1 {
                                self.isConnected = true
                            }
                        }
                    } else if str.starts(with: "[{\"n"){
                        let browse = try! JSONDecoder().decode([Browse].self, from: jsonData)

                        DispatchQueue.main.async {
                            self.browseResult = browse
                        }
                    } else if str.starts(with: "{\"D"){
                        let DAResult = try! JSONDecoder().decode(DA.self, from: jsonData)

                        DispatchQueue.main.async {
                            self.DAResult = DAResult.da
                        }
                    } else if str.starts(with: "{\"A"){
                        let AEResult = try! JSONDecoder().decode(AE.self, from: jsonData)
                        
                        DispatchQueue.main.async {
                            self.AEResult = AEResult.ae
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
