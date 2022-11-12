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
struct DAItem: Codable, Identifiable, Comparable {
    static func < (lhs: DAItem, rhs: DAItem) -> Bool {
        lhs.i < rhs.i
    }
    
    var id = UUID() // : String {i}
    
    let i, v: String
    let t, q: Int
    
    enum CodingKeys: String, CodingKey {
        case i,v,t,q
    }
}
// MARK: - HDA
struct HDAItem: Codable, Identifiable {
    var id = UUID()
    
    let v: String
    let t, q: Int
    
    enum CodingKeys: String, CodingKey {
        case v,t,q
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
    @Published var AEResult = [AEItem]()
    @Published var DAResult = [DAItem]()
    @Published var HDAResult = [HDAItem]()
    @Published var browseResult = [BrowseItem]()
    @Published var tagSet = Set<String>()
    @Published var selectedTag : String?
    @Published var isConnected=false
    @Published var isDAsupported=false
    @Published var isAEsupported=false
    @Published var isHDAsupported=false
    @Published var linesPerTag = 1
    
    var maxAlarm = 0
    private var session: URLSession
    var socket: URLSessionWebSocketTask!
    
    init(){
        self.session = URLSession(configuration: .default, delegate: myDelegate(), delegateQueue: OperationQueue())
    }
    
    func disconnect() {
        isConnected = false
        isDAsupported = false
        isAEsupported = false
        isHDAsupported=false
        DAResult.removeAll()
        AEResult.removeAll()
        HDAResult.removeAll()
        browseResult.removeAll()
        tagSet.removeAll()
        selectedTag=nil
        
        self.socket.cancel(with: .normalClosure, reason: nil)
    }
    
    func connect(server:String) {
        
        let myServer = "ws://"+server+"/OPC/main.opc"
        guard let url = URL(string: myServer) else {
            print("Invalid url string: \(myServer)")
            return
        }
        
        self.socket = session.webSocketTask(with: url)
        
        self.listen()
        self.socket.resume()
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
                            self.isHDAsupported = false
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
                        do{
                            let serverResult = try JSONDecoder().decode([[String:Int]].self, from: jsonData)
                            let da =  serverResult[0].first?.value
                            let ae =  serverResult[1].first?.value
                            let hda =  serverResult[2].first?.value
                            
                            if da == 1 {
                                self.socket.send(.string("browse")){error in
                                    if let error = error {
                                        print("Browsing DA failed with Error \(error.localizedDescription)")
                                    }
                                }
                            } else if hda == 1 {
                                self.socket.send(.string("browseHDA")){error in
                                    if let error = error {
                                        print("Browsing HDA failed with Error \(error.localizedDescription)")
                                    }
                                }
                            }
                            if ae == 1 {
                                sleep(1)
                                self.socket.send(.string("subscribeAE")){_ in}
                            }
                            
                            DispatchQueue.main.async {
                                self.isDAsupported = (da == 1)
                                self.isAEsupported = (ae == 1)
                                self.isHDAsupported = (hda == 1)
                                
                                if da==1 || ae==1 || hda==1 {
                                    self.isConnected = true
                                }
                            }
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
                                var DAResultTemp = self.DAResult
                                DAResultTemp.append(contentsOf: DAResult.first!.value)
                                for item in self.tagSet {
                                    let count = DAResultTemp.filter({$0.i==item}).count
                                    if count > self.linesPerTag {
                                        var countDown = count - self.linesPerTag
                                        while countDown > 0 {
                                            let index = DAResultTemp.firstIndex(where: {$0.i==item})
                                            if index != nil {
                                                DAResultTemp.remove(at: index!)
                                                countDown -= 1
                                            }
                                        }
                                    }
                                }
                                self.DAResult=DAResultTemp
                            }
                        }
                    } else if str.starts(with: "{\"AE"){
                        
                        var AEItemDic=[String:[AEItem]]()
                        
                        do {
                            AEItemDic = try JSONDecoder().decode([String:[AEItem]].self, from: jsonData)
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
                        
                        if (AEItemDic.first?.value.count ?? 0) > 0 {
                            DispatchQueue.main.async {
                                if self.AEResult.count > self.maxAlarm {
                                    self.AEResult.removeFirst(self.AEResult.count - self.maxAlarm)
                                }
                                self.AEResult.append(contentsOf: AEItemDic.first!.value)
                            }
                        }
                    } else if str.starts(with: "{\"HDA"){
                        
                        do {
                            var HDADic = [String:[[String:[HDAItem]]]]()
                        
                            HDADic = try JSONDecoder().decode([String:[[String:[HDAItem]]]].self, from: jsonData)
                            
                            if HDADic.first?.value.first?.first?.value.count ?? 0 > 0 {
                                DispatchQueue.main.async {
                                    self.HDAResult = HDADic.first?.value.first?.first?.value ?? [HDAItem]()
                                }
                            }
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
                    }
                    else if str.starts(with: "{\""){
                        let browse = try! JSONDecoder().decode([String:[BrowseItem]].self, from: jsonData)
                        if (browse.first?.value.count)! > 0 {
                            var browseResultTemp = self.browseResult
                            for i in 0...((browse.first?.value.count)!)-1 {
                                let item = BrowseItem(n:browse.first?.value[i].n ?? "", i:browse.first?.value[i].i ?? "",b:browse.first?.value[i].b ?? 0)
                                item.parent=browse.first!.key
                                if browse.first!.key=="" && browseResultTemp.first(where: {$0.i == item.i}) == nil {
                                    browseResultTemp.append(item)
                                } else {
                                    self.insertNode(name: browse.first!.key, nodes: browseResultTemp, item: item)
                                }
                            }
                            DispatchQueue.main.async {
                                self.browseResult=browseResultTemp //.insert(contentsOf: browseResultTemp, at: 0)
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
