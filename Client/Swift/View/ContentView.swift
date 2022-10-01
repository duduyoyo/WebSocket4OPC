import SwiftUI

struct HorizonLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack{
            configuration.title
            configuration.icon
                .imageScale(.small)
                .foregroundColor(.red)
        }
    }
}

struct ContentView: View {
    
    @ObservedObject var opcModel:OPCModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    init(){
        
        let DAalerts = [DAItem]()
        let AEalerts = [AEItem]()
        let browseResult = [BrowseItem]()
        let servers = OpcServers(da:nil,ae:nil)
        let connected = false
        let DAenabled = false
        let AEenabled = false
        
        opcModel=OPCModel(DAResult:DAalerts, AEResult: AEalerts, browseResult: browseResult, servers: servers, isConnected: connected, isDAsupported: DAenabled, isAEsupported: AEenabled)
    }
    
    func TimeString(time: Int) -> String {

        let date = Date(timeIntervalSince1970: Double(time))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let time = dateFormatter.string(from: date)
        return time
    }
    
    var body: some View {
        TabView() {
            Table(opcModel.DAResult){
                TableColumn("id"){ item in
                    if horizontalSizeClass == .compact {
                        VStack {
                            HStack {
                                Text(item.i)
                                Spacer()
                                Text(item.v)
                                Spacer()
                                Text(item.q==192 ? "Good":"Bad")
                                Spacer()
                                Text(TimeString(time:item.t))
                            }
                        }
                    } else {
                        Text(item.i)
                    }
                }
                TableColumn("value"){ item in
                    Text(item.v)
                }
                TableColumn("quality"){ item in
                    Text(item.q==192 ? "Good":"Bad")
                }
                TableColumn("time"){ item in
                    Text(TimeString(time:item.t))
                }
            }
            .padding()
            .tabItem {
                Label("DA", systemImage: "tag")
            }
            .tag(1)
            
            List(opcModel.AEResult) { item in
                VStack(alignment: .leading) {
                    HStack {
                        Text(item.s+":")
                        Text(item.m)
                    }
                    HStack {
                        Text(item.c)
                        Text(item.sc)
                    }
                    HStack {
                        Text(TimeString(time:item.t))
                        Spacer()
                        Toggle("Accept", isOn:Binding(
                            get: {item.isRecongnized},
                            set: { newValue in
                                item.isRecongnized=newValue
                                
                                // TODO: Recongnize alarm here
                            }
                        )
                        )
                        .toggleStyle(.button)
                        .disabled(item.isRecongnized)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                    }
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
                            get: {opcModel.isDAsupported},
                            set: { newValue in
                                opcModel.isDAsupported=newValue}
                        ))
                        .toggleStyle(.button)
                        .disabled(true)
                        .tint(.green)
                        
                        Toggle("AE", isOn: Binding(
                            get: {opcModel.isAEsupported},
                            set: { newValue in
                                opcModel.isAEsupported=newValue}
                        ))
                        .toggleStyle(.button)
                        .disabled(true)
                        .tint(.green)
                        
                        Toggle("", isOn: Binding(
                            get: {opcModel.isConnected},
                            set: { newValue in
                                opcModel.isConnected=newValue}
                        ))
                        .onChange(of: opcModel.isConnected) { value in
                            if value {
                                self.opcModel.connect()
                            } else {
                                self.opcModel.disconnect()
                            }
                        }
                    }
                }
                
                Section {
                    List(opcModel.browseResult, children:\.children) { myAlertWrapper in
                        if myAlertWrapper.b == 1 {
                            Label(myAlertWrapper.i, systemImage: "plus").labelStyle(HorizonLabelStyle())
                                .onTapGesture(perform: {
                                    opcModel.socket.send(.string("browse: "+myAlertWrapper.i), completionHandler: { error in if let error = error {
                                        print("browse failed with Error \(error.localizedDescription)")
                                    }})
                                })
                        } else {
                            HStack{
                                Text(myAlertWrapper.i)
                                Spacer()
                                Image(systemName: myAlertWrapper.isChecked ? "checkmark.square.fill" : "square")
                                    .foregroundColor(myAlertWrapper.isChecked ? Color(UIColor.systemBlue) : Color.secondary)
                                    .onTapGesture {
                                        myAlertWrapper.isChecked.toggle()
                                        if myAlertWrapper.isChecked {
                                            opcModel.socket.send(.string("subscribe: "+myAlertWrapper.i), completionHandler: { error in
                                                if let error = error {
                                                    print("subscribe failed with Error \(error.localizedDescription)")
                                                }
                                            })
                                        } else {
                                            opcModel.socket.send(.string("unsubscribe: "+myAlertWrapper.i), completionHandler: { error in
                                                if let error = error {
                                                    print("unsubscribe failed with Error \(error.localizedDescription)")
                                                }
                                            })
                                        }
                                    }
                            }
                        }
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
