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
    @ObservedObject private var opcModel = OPCModel()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var maxAlarm = 10
    @State private var server: String = "Server name or IP"

    private var alarmNums = [10, 20, 40, 60 ,80, 100, 120, 150, 200]
    private var linesPerTag = [1, 2, 4, 6 ,8, 10, 15, 20]
    
    init(){
        opcModel.maxAlarm = maxAlarm
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
            Form {
                Section {
                    Picker("Maximum rows per tag", selection: $opcModel.linesPerTag){
                        ForEach(linesPerTag, id:\.self) {
                            Text(String($0))
                        }
                    }
                }
                List(opcModel.DAResult.sorted(by: <)) { item in
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
            }
            .padding()
            .tabItem {
                Label("DA", systemImage: "tag")
            }
            .tag(1)
            
            Form {
                Section {
                    Picker("Maximum alarms to display", selection: $maxAlarm){
                        ForEach(alarmNums, id:\.self) {
                            Text(String($0))
                        }
                    }.onChange(of: maxAlarm) { maxAlarm in opcModel.maxAlarm = maxAlarm}
                }
                List(opcModel.AEResult.suffix(maxAlarm)) { item in
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
            }
            .padding()
            .tabItem {
                Label("AE", systemImage: "bell")
            }
            .tag(2)
            
            Form {
                Section {
                    Picker("", selection: $opcModel.selectedTag){
                        
                        Text("Choose a tag").tag(nil as String?)
                        ForEach(opcModel.tagSet.sorted(by: <), id:\.self) {
                            Text($0).tag($0 as String?)
                        }
                    }
                    
                    DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    HStack{
                        Spacer()
                        Button("Read") {
                            
                            opcModel.socket.send(.string("readRaw: " + opcModel.selectedTag! + " -" + String(startDate.timeIntervalSince1970) + " -" + String(endDate.timeIntervalSince1970)), completionHandler: { error in
                                if let error = error {
                                    print("readRaw failed with Error \(error.localizedDescription)")
                                }
                            })
                        }.disabled(opcModel.selectedTag == nil ? true : false)
                        Spacer()
                    }
                }
                List(opcModel.HDAResult){ item in
                    HStack {
                        Text(item.v)
                        Spacer()
                        Text(item.q==192 ? "Good":"Bad")
                        Spacer()
                        Text(TimeString(time:item.t))
                    }
                }
            }
            .padding()
            .tabItem {
                Label("HDA", systemImage: "calendar.badge.clock")
            }
            .tag(3)
            
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
                        
                        Toggle("HDA", isOn: Binding(
                            get: {opcModel.isHDAsupported},
                            set: { newValue in
                                opcModel.isHDAsupported=newValue}
                        ))
                        .toggleStyle(.button)
                        .disabled(true)
                        .tint(.green)
                    }
                    
                    HStack(alignment: .center) {

                        TextField(text: $server){}
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .textContentType(.URL)
                        
                        Button {
                            if opcModel.isConnected {
                                self.opcModel.disconnect()
                            } else {
                                self.opcModel.connect(server:server)
                            }
                        } label: {
                            if opcModel.isConnected {
                                Text("Disconnect")
                            } else {
                                Text("Connect")
                            }
                        }.buttonStyle(.bordered)
                    }
                }
                
                Section {
                    List(opcModel.browseResult, children:\.children) { myAlertWrapper in
                        if myAlertWrapper.b == 1 {
                            Label(myAlertWrapper.i, systemImage: "plus").labelStyle(HorizonLabelStyle())
                            .onTapGesture(perform: {
                                if opcModel.isDAsupported {
                                    opcModel.socket.send(.string("browse: "+myAlertWrapper.i), completionHandler: { error in
                                        if let error = error {
                                            print("browse DA failed with Error \(error.localizedDescription)")
                                        }
                                    })
                                } else if opcModel.isHDAsupported {
                                    opcModel.socket.send(.string("browseHDA: "+myAlertWrapper.i), completionHandler: { error in
                                        if let error = error {
                                            print("browse HDA failed with Error \(error.localizedDescription)")
                                        }
                                    })
                                }
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
                                            opcModel.tagSet.insert(myAlertWrapper.i)
                                            opcModel.socket.send(.string("subscribe: "+myAlertWrapper.i), completionHandler: { error in
                                                if let error = error {
                                                    print("subscribe failed with Error \(error.localizedDescription)")
                                                }
                                            })
                                        } else {
                                            opcModel.tagSet.remove(myAlertWrapper.i)
                                            if (opcModel.selectedTag==myAlertWrapper.i){
                                                opcModel.selectedTag=nil
                                            }
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
            .tag(4)
        }
    }
}
