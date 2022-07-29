# WebSocket4OPC
Enable WebSocket in OPC DA/AE Server with JSON return, first time ever

DCOM was developed more than 2 decades ago, wich was the technology classic OPC adopted. Young kids out of school enjoy dynamical languages (JavaScript/Python etc) since they are simple and straightforward. They are reluctunt to get their feet wet on this legacy technology. So it is OPC veteran's responsibility to bridge the gap. But how? With the introduction of WebSocket in main languages, WebSocket makes it possible as a glue to combine dynamical languages and legacy DCOM together.<p>
The solution, WebSocket4OPC, is such a pioneer. It utilizes WebSocket as network transportation between various clients and OPC server. All dirty work are wrapped in a native module in server side so all kinds of clients can benefit from simple JSON return. No DCOM to deal with in classic OPC any more, period! 

<h2>Benefits</h2>

.No DCOM required to connect a classic OPC server<br>
.Dynamical languages (JavaScript/Python etc) supportted<br>
.JSON Return<br>
.Intuitive and easy commands instead of long REST API<br>
.No future DCOM vulnerability any more<br>
.Account authentication available<br>
.Secure connection available<br>
.Native mobile application made feasible<br>
.No thousand-page OPC UA documents to go through<br>
.No OPC UA certificate configuration required<br>
.No firewall configuration required<br>
.Edge connection ready<br>

<h2>Pre-requiste</h2>
1. Installation need be done in the same box of OPC DA/AE Server<br>
2. WebSocket feature for IIS need be enabled first<br>
3. Microsoft VC++ Runtim for X64 required (download <a href="https://aka.ms/vs/17/release/vc_redist.x64.exe">here</a> and install)<br>

<h2>Installation</h2>

Download all files from server folder to a local one. Launch a command line with administrator privilege and enter to local folder. Run command "install.bat myAccount myPassword" to complete installation.

To verify, launch browser (Chrome/Safari/Edge) and enter URL "http://localhost/OPC/websocket.html"<p>
<img src="https://user-images.githubusercontent.com/13662339/180631724-758611da-0cb2-4e24-baa3-98663d3a552e.png" width=70%>

<h2>Uninstallation</h2>
Run command "uninstall.bat" in command line from the same local folder.

<h2>Usage</h2><p>
      
1. Browse<p>
   "browse" - Show all children tags under top level<p>
   "browse:tagID" - Show all children tags for a specific tag<p>
   "browse:tagID -countsInPagenation -pageNumber" - Show counted children tags in a pagenation for a specific tag. For example there is 10,000 children tags under a tag and command "browse: tagID -2000 -3" will display 2000 children tags from 4000th to 5999th<p>
   JSON return [{"n": "tagName1", "i": "tagID1", "b": 1}, {"n": "tagName2", "i": "tagID2", "b": 0}, ...] (n - name, i - ID, b - branch)<p>
    When a "browse: Random" command is sent response will be like,<p>
   <img src="https://user-images.githubusercontent.com/13662339/180893490-f05edf30-7e4c-4a77-a3a6-df0c03dc12e7.png" width=70%>

2. Subscribe DA<p>
   "subscribe: tagID1, tagID2, ..." - Add monitored tags to DA server and receive notification when values change<p>

   JOSN return {"DA":[{"i": "tagID1", "v": "20.308", "t": 1643759756000, "q": 192}, {"i": "tagID2", "v": "4", "t": 1643759756230, "q": 192}, ...]}<br>(i - ID, v - value, t - time stamp, q - quality)<p>
   When a "subscribe: Random.Int1" command is sent response will be like,<p>
   <img src="https://user-images.githubusercontent.com/13662339/181158809-677901af-283f-4166-81fe-8c5d368f972f.png" width=70%>
         
3. Unsubscribe DA<p>
   "unsubscribe" - Remove all monitored tags from DA server<p>
   "unsubscribe: tagID1, tagID2, ..." - Remove specific monitored tags from DA server<p>
         
4. Subscribe AE<p>
   "subscribeAE" - Receive notification on alarms and events<p>

   JOSN return {"AE":[{"s":"tagName1","m":"tagName1 Deviation is Low","c":"DEVIATION","sc":"LO","t":1643760803000,"q":192,"tp":4,"ec":2,"st":200,"a":1,"at":""}, {"s":"tagName2","m":"tagName2 Limit is Normal","c":"PVLEVEL","sc":"HIHI","t":1643760808000,"q":192,"tp":4,"ec":1,"st":500,"a":1,"at":""}]}<br>(s - source, m - message, c - condition, sc - sub condition, t - time stamp, q - quality, tp - type, ec - category, st - severity, a - acknowledgement, at - actor)<p>
   When a "subscribeAE" command is sent response will be like,<p>
   <img src="https://user-images.githubusercontent.com/13662339/181421428-078ece71-b514-4e99-99bb-5e2fcb934f3b.png" width=70%>
         
5. Unsubscribe AE<p>
   "unsubscribeAE" - Remove notification on alarms and events<p>
         
6. Disconnect<p>
   "disconnect" - Close connection with server<p>
         
7. Help<p>
   "help" or "?" - Display all supported commands and usages<p>
         
<h2>Screen shots from all kinds of clients' outputs</h2>
<h4>Python</h4>
<h4>C#</h4>
<h4>C/C++</h4>
<h4>Java</h4>
