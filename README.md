# WebSocket4OPC
Enable WebSocket in OPC DA/AE Server with JSON return, first time ever

DCOM was developed more than 2 decades ago, wich was the pillar of classic OPC. Young kids out of school love dynamical languages (JavaScript/Python etc) since they are simple and straightforward. They are reluctunt to get their feet wet on this legacy technology. Luckily with the wide adoption of WebSocket in most popular languages, WebSocket makes it possible to glue dynamical languages and legacy DCOM together.<p>
This revolutionary solution, WebSocket4OPC, brings unparalleled experience to your desktop or mobile device. It utilizes WebSocket as network transportation between quite a few different clients and classic OPC server. Meanwhile it has equipped all required features to make sure OPC data can be accessed through Internet safely and securely. Remember - all these are achieved without using DCOM, period! 

<h2>Benefits</h2>

.No DCOM when connecting to a classic OPC server<br>
.Support dynamical languages (JavaScript/Python etc)<br>
.Return in standard JSON format<br>
.Intuitive and easy-to-remember commands instead of long REST API<br>
.No future DCOM vulnerability to worry<br>
.Account authentication available<br>
.Secure connection available<br>
.Native mobile APP made feasible<br>
.No tedious thousand-page OPC UA documents to read<br>
.No OPC UA certificate configuration handle<br>
.No OPC UA firewall configuration<br>
.Edge or Gateway deployment ready<br> 

<h2>Pre-requiste</h2>
1. Installation need be done in the same box of classic OPC DA/AE Server<br>
2. WebSocket feature for IIS need be enabled in server box<br>
3. Microsoft VC++ Runtim for X64 required (download <a href="https://aka.ms/vs/17/release/vc_redist.x64.exe">here</a> and install)<br>

<h2>Installation</h2>

Download all files from server folder to a desired one. Launch a command line with administrator privilege and enter to downloaded folder. Run command "install.bat userAccount userPassword" to complete installation. userAccount need have administrator privilege.

To verify, launch browser (Chrome/Safari/Edge) and enter URL "http://localhost/OPC/websocket.html"<p>
<img src="https://user-images.githubusercontent.com/13662339/180631724-758611da-0cb2-4e24-baa3-98663d3a552e.png" width=70%>

<h2>Uninstallation</h2>
Run command "uninstall.bat" in command line with administrator privilege from the downloaded folder to uninstall.

<h2>Usage</h2><p>
      
1. Browse<p>
   "browse" - Show all children tags under top level<p>
   "browse:tagID" - Show all children tags for a specific tag<p>
   "browse:tagID -countsInPagenation -pageNumber" - Show counted children tags in a pagenation for a specific tag. For example there are 10,000 children tags available under a specific tag and command "browse: tagID -2000 -3" will display 2000 children tags from 4000th to 5999th to correspond to page 3<p>
   JSON return [{"n": "tagName1", "i": "tagID1", "b": 1}, {"n": "tagName2", "i": "tagID2", "b": 0}, ...]<br>(n - name, i - ID, b - branch)<p>
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
         
<h2>Sample code output</h2>
Sample codes for different languages (Python/Swift/C#/C++/Java) are available in client folder<br>

<h4>Python</h4>
<img src="https://user-images.githubusercontent.com/13662339/181852043-03793d2e-78de-45bb-96d6-f3e5255501c4.png" width=70%>

<h4>Swift</h4>
<img src="https://user-images.githubusercontent.com/13662339/182004587-7c5b288a-3955-4689-8c9c-ebe2c81bd4e8.png" width=30%>

<h4>C#</h4>
<img src="https://user-images.githubusercontent.com/13662339/181852448-7b059383-01dc-4b9f-b095-6d551b1f591f.png" width=70%>

<h4>C++</h4>
<img src="https://user-images.githubusercontent.com/13662339/181853113-1b51114d-3318-41e9-b847-01d7bc3ceb61.png" width=70%>

<h4>Java</h4>
<img src="https://user-images.githubusercontent.com/13662339/181853551-1bf4f9e4-103b-43f5-b856-8b7dec7f9938.png" width=70%>

<h2>Roadmap</h2>
- Read/write feature in DA upon request<br>
- HDA feature upon request<br>
- Full-fledged open source native client for iOS<br>
