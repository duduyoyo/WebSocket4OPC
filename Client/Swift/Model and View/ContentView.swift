import SwiftUI

struct AlertWrapper: Identifiable {
    let id = UUID()
    var alert: DA
    var servers:OpcServers
    var browseResult:[Browse]?
}

class ViewModel{
    var alertWrapper = [AlertWrapper] ()
}

struct ContentView: View {
    
    @State var buttonLabel = "Disconnect"
    var myModel : ViewModel
    
    @ObservedObject var controller:WebSocketController
    
    init(){
        myModel = ViewModel()
        controller = WebSocketController(alertWrapper:myModel.alertWrapper)
    }
    
    func alertMapped(myAlertWrapper: AlertWrapper) -> String {
       
        if myAlertWrapper.alert.da != nil {
            
            let timestamp = Double(myAlertWrapper.alert.da![0].t)
            let date = Date(timeIntervalSince1970: timestamp)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let time = dateFormatter.string(from: date)
            
            return myAlertWrapper.alert.da![0].i+": "+myAlertWrapper.alert.da![0].v+"@"+time
            
        } else if myAlertWrapper.servers.da != nil && myAlertWrapper.servers.ae != nil {
            var result = ""
            
            if myAlertWrapper.servers.da == 1 {
                result = "DA : Available"
            }else{
                result = "DA : N/A"
            }
            
            if myAlertWrapper.servers.ae == 1 {
                result = result + "\t\t\t" + "AE : Available"
            }else{
                result = result + "\t\t\t\t" + "AE : N/A"
            }
            
            return result
            
        } else if myAlertWrapper.browseResult != nil {
            var result = "Top\n\t"
            myAlertWrapper.browseResult!.forEach { browse in
                
                if browse.b == 1{
                    result = result+browse.n+" +\n\t"
                }else{
                    result = result+browse.n+" -\n\t"
                }
            }
            return result
        }
        
        return "n/a"
    }
    
    var body: some View {
        
        VStack(spacing: 1) {
            List(controller.alertWrapper){ myAlertWrapper in
                let result = alertMapped(myAlertWrapper:myAlertWrapper)
                Text(result)
            }
            
            Divider()
            
            Button(buttonLabel, action: {
                if self.buttonLabel == "Connect" {
                    self.controller.connect()
                } else {
                    self.controller.disconnect()
                }
                self.buttonLabel = self.buttonLabel == "Connect" ? "Disconnect" : "Connect"
                
            }).padding()
        }
    }
}
