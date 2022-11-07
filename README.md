# WebSocket4OPC
Enable WebSocket in OPC DA/AE/HDA Server with JSON return, FIRST TIME ever!

DCOM was developed more than 2 decades ago, which was the pillar of classic OPC. Young kids out of school today love dynamical languages (JavaScript/Python etc) since they can grasp them easily and quickly. They are reluctunt to get their feet wet on the legacy DCOM technology. Luckily with the wide adoption of WebSocket in most popular languages, WebSocket makes it possible to glue dynamical languages and legacy DCOM together.<p>
This revolutionary solution, WebSocket4OPC, brings unparalleled experience to your desktop and mobile device. It utilizes WebSocket as network transportation layer between quite a few different clients and classic OPC servers. Meanwhile it has come with all built-in required features for OPC data to be accessed through Internet safely and securely. Remember - all these are achieved without DCOM at all, period! 

<h2>Benefits</h2>

.No DCOM when connecting to a classic OPC server<br>
.Support dynamical languages (JavaScript/Python etc)<br>
.Return in standard JSON format<br>
.Intuitive and easy-to-remember commands instead of checking long REST API syntax<br>
.No future DCOM vulnerability to worry<br>
.Built-in account authentication by IIS<br>
.Built-in secure connection by IIS<br>
.Make native mobile APP development feasible<br>
.No tedious 1250-page OPC UA documents to check<br>
.No OPC UA certificate configuration<br>
.No OPC UA firewall configuration<br>
.Cross-platform gurantted(Linux/Mac/Windows)<br>
.Deploy as Edge or Gateway device without any custom hardware<br> 

<h2>Pre-requiste</h2>
1. Install in the same box where classic OPC DA/AE/HDA server is installed<br>
2. WebSocket feature for IIS need be enabled in the same server box<br>
3. Microsoft VC++ Runtim for X64 required (download <a href="https://aka.ms/vs/17/release/vc_redist.x64.exe">here</a> and install if you don't have)<br>

<h2>Installation</h2>

Download all files from server folder to your desired one. Launch a command line with administrator privilege and enter to your download folder. Run command "install.bat userAccount userPassword" to complete installation. userAccount/userPassword need be replaced with your own Windows account/password and make sure that account has administrator privilege. If you have previous installation, uninstall it first.

To verify, launch browser (Chrome/Safari/Edge) and enter URL "http://localhost/OPC/websocket.html"<p>
<img src="https://user-images.githubusercontent.com/13662339/199052370-58d084ef-170e-4d40-87d0-295766d36b43.png" width=70%>

<h2>Uninstallation</h2>
Run command "uninstall.bat" in command line with administrator privilege from the your download folder to uninstall.

<h2>Usage</h2><p>
      
1. Browse<p>
   There are two sets of browse commands for DA and HDA servers respectively.<p>
   "browse" - Show all children tags under top level of DA server<p>
   "browseHDA" - Show all children tags under top level of HDA server<p>
   "browse:tagID" - Show all children tags for a tag of DA server<p>
   "browseHDA:tagID" - Show all children tags for a tag of HDA server<p>
   "browse:tagID -countsInPagenation -pageNumber" - Show a limited number of children tags in pagenation for a tag of DA server. For example there are 10,000 children tags available under a specific tag and command "browse: tagID -2000 -3" will display 2000 children tags from 4000th to 5999th to correspond to page 3 in DA server<p>
    "browseHDA:tagID -countsInPagenation -pageNumber" - Show a limited number of children tags in pagenation for a tag of HDA server. For example there are 10,000 children tags available under a specific tag and command "browseHDA: tagID -2000 -3" will display 2000 children tags from 4000th to 5999th to correspond to page 3 in HDA server<p>
   JSON return {"parentNodeID":[{"n": "tagName1", "i": "tagID1", "b": 1}, {"n": "tagName2", "i": "tagID2", "b": 0}, ...]}<br>(parentNodeID - parent node id or "" at top level, n - name, i - ID, b - branch)<p>
    When a "browse: Random" command is sent response will be like,<p>
    <img src="https://user-images.githubusercontent.com/13662339/193419607-97d11de8-4116-4b0e-a767-e8c810c4ce01.png" width=70%><p>
    When a "browseHDA: Random" command is sent response will be like,<p>
    <img src="https://user-images.githubusercontent.com/13662339/198896314-9b2dd8cb-6d62-4c78-9aaa-e4dbe4df2a46.png" width=70%>

2. Subscribe tags to DA server<p>
   "subscribe: tagID1, tagID2, ..." - Add monitored tags to DA server and receive updates when new values are available<p>

   JSON return {"DA":[{"i": "tagID1", "v": "20.308", "t": 1643759756, "q": 192}, {"i": "tagID2", "v": "4", "t": 1643769859, "q": 192}, ...]}<br>(i - ID, v - value, t - time stamp in epoch UTC, q - quality)<p>
   When a "subscribe: Random.Int1" command is sent response will be like,<p>
   <img src="https://user-images.githubusercontent.com/13662339/199060884-932ef225-0baf-43ca-a90a-d562dcb02a39.png" width=70%>
         
3. Unsubscribe tags from DA server<p>
   "unsubscribe" - Remove all monitored tags from DA server<p>
   "unsubscribe: tagID1, tagID2, ..." - Remove specific monitored tags from DA server<p>
         
4. Subscribe to AE server<p>
   "subscribeAE" - Receive notification on alarms and events<p>

   JSON return {"AE":[{"s":"tagName1","m":"tagName1 Deviation is Low","c":"DEVIATION","sc":"LO","t":1643760803,"q":192,"tp":4,"ec":2,"st":200,"a":1,"at":""}, {"s":"tagName2","m":"tagName2 Limit is Normal","c":"PVLEVEL","sc":"HIHI","t":1643760808,"q":192,"tp":4,"ec":1,"st":500,"a":1,"at":""}]}<br>(s - source, m - message, c - condition, sc - sub condition, t - time stamp, q - quality, tp - type, ec - category, st - severity, a - acknowledgement, at - actor)<p>
   When a "subscribeAE" command is sent response will be like,<p>
   <img src="https://user-images.githubusercontent.com/13662339/199061346-0484492b-928a-467b-b9b6-143930bffd1e.png" width=70%>
         
5. Unsubscribe from AE server<p>
   "unsubscribeAE" - Remove notification on alarms and events<p>
         
6. Read history data from HDA server<p>
   "readRaw: tagID1, tagID2 -startTimeStamp -endTimeStamp" - Read tags' history data based on start and end time stamps<p>
  
   JSON return {"HDA":[{"tagID1":[{"v":"24201","t":1665632091,"q":192}, {"v":"19168","t":1665632092,"q":192},...]}, {"tagID2":[{"v":"24","t":1665632091,"q":192}, {"v":"168","t":1665632092,"q":192},...]}]}<br>(v - value, t - time stamp in epoch UTC, q - quality)<p>
   When a "readRaw: Random.Int1, Random.Int2 -1667155333 -1667156333" command is sent response will be like,<p>
   <img src="https://user-images.githubusercontent.com/13662339/198896806-5f9697d9-13f6-4f20-8f56-0337bc40ef04.png" width=70%>
   
7. Disconnect<p>
   "disconnect" - Close connection with server<p>
         
8. Help<p>
   "help" or "?" - Display all supported commands and usages<p>
         
<h2>Sample code output</h2>
Sample codes for different languages (Python/Swift/C#/C++/Java) are available in client folder<br>

<h4>Python</h4>
<img src="https://user-images.githubusercontent.com/13662339/199040885-97004321-870b-4c31-b30a-1f3370939bd2.png" width=70%>

<h4>Swift</h4>


<div style="display: table">


https://user-images.githubusercontent.com/13662339/200226922-060a4473-e3ec-4900-840d-5ccd4404fb10.mp4


<img width=30% src="https://user-images.githubusercontent.com/13662339/200226063-9657a8d7-6c40-4a0c-a2a4-f79b2a1825c6.PNG">
<img width=30% src="https://user-images.githubusercontent.com/13662339/200226217-cd01d396-355b-4699-bd8e-f25dc3649ea0.PNG">
<img width=30% src="https://user-images.githubusercontent.com/13662339/200226289-1ed0c8bf-570f-4e30-b744-d0442b86d072.PNG">
<img width=30% src="https://user-images.githubusercontent.com/13662339/200226340-732b7bf4-b5e7-4a94-9167-2b78b06cfcd0.PNG">

</div>

<h4>C#</h4>
<img src="https://user-images.githubusercontent.com/13662339/199042090-4d95864b-4bf8-4415-9e37-921b9479ef0f.png" width=70%>

<h4>C++</h4>
<img src="https://user-images.githubusercontent.com/13662339/199049077-3f683ba7-9ec2-4072-a44f-a142426ee618.png" width=70%>

<h4>Java</h4>
<img src="https://user-images.githubusercontent.com/13662339/199050631-0c1728af-d738-4d29-b600-f72c267e0a45.png" width=70%>

<h2>Roadmap</h2>
- Read/write feature in DA upon request<br>
- HDA feature upon request<br>
- Full-fledged open source native client for iOS<br>
