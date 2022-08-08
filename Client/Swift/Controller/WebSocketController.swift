import Foundation
import SwiftUI

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
                    print(str)
                    
                    DispatchQueue.main.async {
                        self.alertWrapper.append(AlertWrapper(alert:str))
                    }
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
