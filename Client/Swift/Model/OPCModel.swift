import Foundation
import SwiftUI

// MARK: Data Model
// MARK: - AE
class AEItem: Codable, Identifiable {
    var id = UUID() //: String {s}
    var isRecongnized = false
    
    let s, m, c, sc: String
    let t, q, tp, ec: Int
    let st, a: Int
    let at: String
    
    init(s:String,m:String,c:String,sc:String,at:String,t:Int,q:Int,tp:Int,ec:Int,st:Int,a:Int) {
        self.s=s
        self.m=m
        self.c=c
        self.sc=sc
        self.at=at
        self.t=t
        self.q=q
        self.tp=tp
        self.ec=ec
        self.st=st
        self.a=a
    }
    
    enum CodingKeys: String, CodingKey {
        case s, m, c, sc,t, q, tp, ec,st, a,at
    }
}

// MARK: - DA
struct DAItem: Codable, Identifiable {
    var id = UUID() // : String {i}
    
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
class BrowseItem: Codable, Identifiable {
    var id : String {i}
    var isChecked = false
    var parent=""
    
    let n, i: String
    let b: Int
    
    enum CodingKeys: String, CodingKey {
        case i,n,b
    }
    
    init(n:String,i:String,b:Int) {
        self.n=n
        self.i=i
        self.b=b
    }

    var children: [BrowseItem]?
}

class myDelegate: NSObject, URLSessionWebSocketDelegate {
}

class OPCModel : ObservableObject {
    // MARK: State Model
    @Published var AEResult : [AEItem]
    @Published var DAResult : [DAItem]
    @Published var browseResult : [BrowseItem]
    @Published var isConnected:Bool
    @Published var isDAsupported:Bool
    @Published var isAEsupported:Bool
    
    private var session: URLSession
    var socket: URLSessionWebSocketTask!
    
    init(DAResult : [DAItem], AEResult : [AEItem], browseResult :[BrowseItem], servers : OpcServers, isConnected:Bool, isDAsupported:Bool, isAEsupported:Bool){
        
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
                    
                    } else if str.starts(with: "{\"DA"){
                        var DAResult=[String:[DAItem]]()
                        
                        do{
                            DAResult = try JSONDecoder().decode([String:[DAItem]].self, from: jsonData)
                        } catch let DecodingError.dataCorrupted(context) {
                            print(str)
                            print(context)
                        } catch let DecodingError.keyNotFound(key, context) {
                            print("Key '\(key)' not found:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        } catch let DecodingError.valueNotFound(value, context) {
                            print("Value '\(value)' not found:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        } catch let DecodingError.typeMismatch(type, context)  {
                            print("Type '\(type)' mismatch:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        } catch {
                            print("error: ", error)
                        }
                        
                        if (DAResult.first?.value.count ?? 0) > 0 {
                            DispatchQueue.main.async {
                                self.DAResult = DAResult.first!.value
                            }
                        }
                    } else if str.starts(with: "{\"AE"){
                        
                        var AEResult=[String:[AEItem]]()
                        
                        do {
                            AEResult = try JSONDecoder().decode([String:[AEItem]].self, from: jsonData)
                        } catch let DecodingError.dataCorrupted(context) {
                            print(context)
                        } catch let DecodingError.keyNotFound(key, context) {
                            print("Key '\(key)' not found:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        } catch let DecodingError.valueNotFound(value, context) {
                            print("Value '\(value)' not found:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        } catch let DecodingError.typeMismatch(type, context)  {
                            print("Type '\(type)' mismatch:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        } catch {
                            print("error: ", error)
                        }
                        
                        if (AEResult.first?.value.count ?? 0) > 0 {
                            DispatchQueue.main.async {
                                self.AEResult.append(contentsOf: AEResult.first!.value)
                            }
                        }
                    } else if str.starts(with: "{\""){
                        let browse = try! JSONDecoder().decode([String:[BrowseItem]].self, from: jsonData)
                        if (browse.first?.value.count)! > 0 {
                            for i in 0...((browse.first?.value.count)!)-1 {
                                let item = BrowseItem(n:browse.first?.value[i].n ?? "", i:browse.first?.value[i].i ?? "",b:browse.first?.value[i].b ?? 0)
                                item.parent=browse.first!.key
                                DispatchQueue.main.async {
                                    if browse.first!.key=="" && self.browseResult.first(where: {$0.i == item.i}) == nil {
                                        self.browseResult.append(item)
                                    } else {
                                        self.insertNode(name: browse.first!.key, nodes: self.browseResult, item: item)
                                    }
                                }
                            }
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
    
    func insertNode(name:String, nodes: [BrowseItem], item:BrowseItem)->Void{
        let currentNode = nodes.first(where: {value in
            value.i==name
        })
        if currentNode != nil {
            if currentNode?.children == nil {
                currentNode?.children = [BrowseItem]()
            }
            
            if currentNode?.children?.first(where: {$0.i == item.i}) == nil {
                currentNode?.children?.append(item)
            }
        } else {
            
            nodes.forEach({node in
                if node.children != nil {
                    let children = (node.children)!
                    insertNode(name: name, nodes: children, item: item)
                }
            })
        }
    }
}
