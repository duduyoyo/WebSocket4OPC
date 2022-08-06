import SwiftUI

struct AlertWrapper: Identifiable {
    let id = UUID()
    var alert: String
}

class ViewModel{
    var alertWrapper = [AlertWrapper] ()
}

struct ContentView: View {
    
    @State var buttonLabel = "Disconnect"
    var myModel : ViewModel
    
    @ObservedObject var controoler:WebSocketController
    
    init(){
        myModel = ViewModel()
        controoler = WebSocketController(alertWrapper:myModel.alertWrapper)
    }
    
    var body: some View {
        
        VStack(spacing: 1) {
            List(controoler.alertWrapper){ myAlertWrapper in
                Text(myAlertWrapper.alert)
            }
            
            Divider()
            
            Button(buttonLabel, action: {
                if self.buttonLabel == "Connect" {
                    self.controoler.connect()
                } else {
                    self.controoler.disconnect()
                }
                self.buttonLabel = self.buttonLabel == "Connect" ? "Disconnect" : "Connect"
                
            }).padding()
        }
    }
}
