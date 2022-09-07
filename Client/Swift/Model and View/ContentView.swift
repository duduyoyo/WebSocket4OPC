import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var socket:WebSocketController
    
    func browseResult(myAlertWrapper: Browse) -> String {
        
        var result = ""
        
        if myAlertWrapper.b == 1{
            result = result+myAlertWrapper.i+" +\n\t"
        }else{
            result = result+myAlertWrapper.i+" -\n\t"
        }
        return result
    }
    
    func DAMapped(myAlertWrapper: DAItem) -> String {
        let timestamp = Double(myAlertWrapper.t)
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let time = dateFormatter.string(from: date)
        
        return myAlertWrapper.i+": "+myAlertWrapper.v+"@"+time
    }
    
    func AEMapped(myAlertWrapper: AEItem) -> String {
        let timestamp = Double(myAlertWrapper.t)
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let time = dateFormatter.string(from: date)
        
        return myAlertWrapper.s+": "+myAlertWrapper.m+" "+myAlertWrapper.c+" "+myAlertWrapper.sc+"@"+time
    }
    
    var body: some View {
        
        TabView() {
            VStack(alignment: .leading) {
               
                List(socket.DAResult) { myAlertWrapper in
                    let result = DAMapped(myAlertWrapper:myAlertWrapper)
                    Text(result)
                }
            }
            .padding()
            .tabItem {
                Label("DA", systemImage: "tag")
            }
            .tag(1)
            
            VStack(alignment: .leading) {
               
                List(socket.AEResult) { myAlertWrapper in
                    let result = AEMapped(myAlertWrapper:myAlertWrapper)
                    Text(result)
                }
            }
            .padding()
            .tabItem {
                Label("AE", systemImage: "bell")
            }
            .tag(2)
            
            Form {
                Section {
                    
                    HStack(alignment: .center) {
                        Toggle("DA", isOn: Binding(
                            get: {socket.isDAsupported},
                            set: { newValue in
                                socket.isDAsupported=newValue}
                        ))
                        .toggleStyle(.button)
                        .disabled(true)
                        .tint(.green)
                        
                        Toggle("AE", isOn: Binding(
                            get: {socket.isAEsupported},
                            set: { newValue in
                                socket.isAEsupported=newValue}
                        ))
                        .toggleStyle(.button)
                        .disabled(true)
                        .tint(.green)
                        
                        Toggle("", isOn: Binding(
                            get: {socket.isConnected},
                            set: { newValue in
                                socket.isConnected=newValue}
                        ))
                        .onChange(of: socket.isConnected) { value in
                            if value {
                                self.socket.connect()
                            } else {
                                self.socket.disconnect()
                            }
                        }
                    }
                }
                
                Section {
                    List(socket.browseResult) { myAlertWrapper in
                        let result = browseResult(myAlertWrapper:myAlertWrapper)
                        Text(result)
                    }
                }
            }
            .padding()
            .tabItem {
                Label("Setting", systemImage: "gearshape")
            }
            .tag(3)
        }
    }
}
