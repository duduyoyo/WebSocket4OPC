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
.No tedious 1250-page OPC UA documents to check<br>
.No OPC UA certificate configuration handle<br>
.No OPC UA firewall configuration<br>
.Edge or Gateway deployment ready<br> 

<h2>Pre-requiste</h2>
1. Installation need be done in the same box of classic OPC DA/AE Server<br>
2. WebSocket feature for IIS need be enabled in server box<br>
3. Microsoft VC++ Runtim for X64 required (download <a href="https://aka.ms/vs/17/release/vc_redist.x64.exe">here</a> and install)<br>

<h2>Installation</h2>

Download all files from server folder to a desired one. Launch a command line with administrator privilege and enter to downloaded folder. Run command "install.bat userAccount userPassword" to complete installation. userAccount/userPassword need be replaced with your own Windows account/password and make sure account has administrator privilege.

To verify, launch browser (Chrome/Safari/Edge) and enter URL "http://localhost/OPC/websocket.html"<p>
<img src="https://user-images.githubusercontent.com/13662339/180631724-758611da-0cb2-4e24-baa3-98663d3a552e.png" width=70%>

<h2>Uninstallation</h2>
Run command "uninstall.bat" in command line with administrator privilege from the downloaded folder to uninstall.

<h2>Usage</h2><p>
      
1. Browse<p>
   "browse" - Show all children tags under top level<p>
   "browse:tagID" - Show all children tags for a specific tag<p>
   "browse:tagID -countsInPagenation -pageNumber" - Show counted children tags in a pagenation for a specific tag. For example there are 10,000 children tags available under a specific tag and command "browse: tagID -2000 -3" will display 2000 children tags from 4000th to 5999th to correspond to page 3<p>
   JSON return {"parentNodeID":[{"n": "tagName1", "i": "tagID1", "b": 1}, {"n": "tagName2", "i": "tagID2", "b": 0}, ...]}<br>(parentNodeID - parent node id or "" at top level, n - name, i - ID, b - branch)<p>
    When a "browse: Random" command is sent response will be like,<p>
   <img src="https://user-images.githubusercontent.com/13662339/193419607-97d11de8-4116-4b0e-a767-e8c810c4ce01.png" width=70%>

2. Subscribe DA<p>
   "subscribe: tagID1, tagID2, ..." - Add monitored tags to DA server and receive notification when values change<p>

   JOSN return {"DA":[{"i": "tagID1", "v": "20.308", "t": 1643759756, "q": 192}, {"i": "tagID2", "v": "4", "t": 1643769859, "q": 192}, ...]}<br>(i - ID, v - value, t - time stamp, q - quality)<p>
   When a "subscribe: Random.Int1" command is sent response will be like,<p>
   <img src="https://user-images.githubusercontent.com/13662339/186764926-2ab5b662-3b09-4413-a6d9-8e095bac05b2.png" width=70%>
         

3. Unsubscribe DA<p>
   "unsubscribe" - Remove all monitored tags from DA server<p>
   "unsubscribe: tagID1, tagID2, ..." - Remove specific monitored tags from DA server<p>
         
4. Subscribe AE<p>
   "subscribeAE" - Receive notification on alarms and events<p>

   JOSN return {"AE":[{"s":"tagName1","m":"tagName1 Deviation is Low","c":"DEVIATION","sc":"LO","t":1643760803,"q":192,"tp":4,"ec":2,"st":200,"a":1,"at":""}, {"s":"tagName2","m":"tagName2 Limit is Normal","c":"PVLEVEL","sc":"HIHI","t":1643760808,"q":192,"tp":4,"ec":1,"st":500,"a":1,"at":""}]}<br>(s - source, m - message, c - condition, sc - sub condition, t - time stamp, q - quality, tp - type, ec - category, st - severity, a - acknowledgement, at - actor)<p>
   When a "subscribeAE" command is sent response will be like,<p>
   <img src="https://user-images.githubusercontent.com/13662339/186767927-f1747b3b-ff88-4bd2-89ac-bf8414957f3f.png" width=70%>
         
5. Unsubscribe AE<p>
   "unsubscribeAE" - Remove notification on alarms and events<p>
         
6. Disconnect<p>
   "disconnect" - Close connection with server<p>
         
7. Help<p>
   "help" or "?" - Display all supported commands and usages<p>
         
<h2>Sample code output</h2>
Sample codes for different languages (Python/Swift/C#/C++/Java) are available in client folder<br>

<h4>Python</h4>
<img src="https://user-images.githubusercontent.com/13662339/193420183-a1edf74b-d4f4-403e-ab09-0677b796634b.png" width=70%>

<h4>Swift</h4>
<div style="display: table">
<img width=30% src="https://user-images.githubusercontent.com/13662339/193419727-99181492-19eb-4361-ba25-824f73b6398f.PNG">
<img width=30% src="https://user-images.githubusercontent.com/13662339/193419779-9f91e4cd-5ad1-4c6d-a71c-5b0888190f97.PNG">
<img width=30% src="https://user-images.githubusercontent.com/13662339/193419792-3c944e16-a213-4dc9-ad5f-cd3dce49e5f0.PNG">
<img width=30% src="https://user-images.githubusercontent.com/13662339/193419832-ce5c0e0a-4449-49f5-873a-c78b8c58dc6e.PNG">
<img width=30% src="https://user-images.githubusercontent.com/13662339/193419879-3e8d645f-1d61-4242-8a7c-24a908da7f08.PNG">
<img width=30% src="https://user-images.githubusercontent.com/13662339/193419889-772ab8bf-73b1-47e2-baa2-d42b77d76240.PNG">

</div>
<h4>C#</h4>
<img src="https://user-images.githubusercontent.com/13662339/193420280-b0e27b8b-f308-49c5-a377-3ca03fea8d42.png" width=70%>

<h4>C++</h4>
<img src="https://user-images.githubusercontent.com/13662339/193420342-7b2b0f85-6d1f-4772-9c30-00395200a4a0.png" width=70%>

<h4>Java</h4>
<img src="https://user-images.githubusercontent.com/13662339/193421170-798595d9-f926-4813-aead-8dd2b0625ab9.png" width=70%>

<h2>Roadmap</h2>
- Read/write feature in DA upon request<br>
- HDA feature upon request<br>
- Full-fledged open source native client for iOS<br>
