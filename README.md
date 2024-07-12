# WebSocket4OPC
Enable WebSocket in OPC DA/AE/HDA Server with JSON return, FIRST TIME ever!

DCOM was developed more than 2 decades ago, which was the pillar of classic OPC. Nowadays people embrace for dynamical languages (JavaScript/Python etc) due to their simplicity and refuse to be trapped in DCOM configuration hell. Luckily with the popular adoption of WebSocket by most modern programming languages, it is possible to glue dynamical languages and legacy DCOM together.<p>
This innovative solution is a perfect combination of all its tech stack's advantages as below,<p>
    1. WebSocket (standard network protocol for cross-platform/full duplex)<br>
    2. Microsoft IIS (authorization/authentication/firewall/certificate)<br>
    3. Classic OPC (the most widely adopted industry interfaces)<p>
Comparing with OPC UA, is there any piece missing? Not all but simple, fast and straightforward. OPC data can be accessed safely and securely through Internet. Unparalleled experience to your desktop and mobile device is around the corner. Say GoodBye to DCOM!

<h2>Benefits</h2>

.Worldwide the exclusive solution to access AE/HDA data in Python/JavaScript<br>
.No DCOM when connecting to a classic OPC server<br>
.No future DCOM vulnerability or hardening to worry<br>
.Support dynamical languages (JavaScript/Python etc)<br>
.No expensive corporate membership fee<br>
.No OPC or 3rd party SDK needed<br>
.Intuitive and easy-to-remember commands instead of long REST API URL<br>
.Built-in account authorization and authentication by IIS<br>
.Built-in secure connection with certificate by IIS<br>
.Native mobile APP development feasible<br>
.No tedious 1250-page OPC UA documents to consult<br>
.No OPC UA certificate configuration<br>
.No OPC UA firewall configuration<br>
.No OPC DA->UA conversion needed<br>
.Cross-platform in client gurantted(Linux/Mac/Windows)<br>
.Edge or Gateway deployment ready without any expensive custom hardware<br> 

<h2>Pre-requiste</h2>
1. Install in the same server box where classic OPC DA/AE/HDA server is running<br>
2. WebSocket feature for IIS need be enabled in the same server box<br>
3. Microsoft VC++ Runtim for X64 required (download <a href="https://aka.ms/vs/17/release/vc_redist.x64.exe">here</a> and install it if needed)<br>

<h2>Installation</h2>

Download all files from server folder to your desired one. Launch a command line with administrator privilege and enter to your download folder. Run command "install.bat userAccount userPassword" to complete installation. userAccount/userPassword need be replaced with your own Windows account/password and make sure that account has administrator privilege. This account is only used by IIS to configure a new app pool and not used by this solution or stored anywhere else. If you have previous installation, uninstall it first.

To verify, launch browser (Chrome/Safari/Edge) and enter URL "http://localhost/OPC/websocket.html"<p>
<img src="https://user-images.githubusercontent.com/13662339/199052370-58d084ef-170e-4d40-87d0-295766d36b43.png" width=70%>

If installed in a multiple server environment, a config file under program data folder is available to specify your desired server based on its prog ID<p>

<h2>Uninstallation</h2>
Run command "uninstall.bat" in command line with administrator privilege in your download folder.

<h2>Usage</h2><p>
      
1. DA commands<p>
1.1 Browse<p>
   "browse" - Show all child tags under top level of DA server<p>
   "browse:tagID" - Show all child tags under a parent tag of DA server<p>
   "browse:tagID -countsInPagenation -pageNumber" - Show a subset of children tags based on pagenation under a specific tag in DA server. For example, if there are total 10,000 children tags under a specific tag, command "browse: tagID -2000 -3" will only display a tag's 2000 children tags (4000th to 5999th) for 3rd page in DA server<p>
    
   JSON returns {"parentNodeID":[{"n": "tagName1", "i": "tagID1", "b": 1}, {"n": "tagName2", "i": "tagID2", "b": 0}, ...]}<br>(parentNodeID - parent node id or "" at top level, n - name, i - ID, b - branch)<p>
    When command "browse: Random" is sent, response will be like<p>
    <img src="https://user-images.githubusercontent.com/13662339/193419607-97d11de8-4116-4b0e-a767-e8c810c4ce01.png" width=70%><p>
1.2 Read<p> 
   "read: tagID1, tagID2, ..."- Read tag latest values from DA server<p>

   JSON returns {"DA":[{"i": "tagID1", "v": "20.308", "t": 1643759756112, "q": 192}, {"i": "tagID2", "v": "4", "t": 1643769859342, "q": 192}, ...]}<br>(i - ID, v - value, t - time stamp in milliseconds of epoch UTC, q - quality)<p>
   When command "read: Random.Real4, Random.Int2" is sent, response will be like<p>
   <img src="https://user-images.githubusercontent.com/13662339/216796465-f2822c20-9ca2-42f6-8e14-c5ce848e43bf.png" width=70%>  
  
   1.3 Write<p>
   "write: tagID1 -value1; tagID2 -value2; ..."- Write tag values to DA server. It is strongly recommended NOT to use this command in a production environment when Internet access is available. Contact developer to have a version without this command for production use.<p>

   No JSON return but writing status (success/failure) will be reported as info. Use read command to verify writing's success<p>
   When command "write: Bucket Brigade.Int2 -34; Random.Int2 -12" is sent, response will be like<p>
   <img src="https://user-images.githubusercontent.com/13662339/232327090-7744a9be-3300-4b00-a6f7-e7c2f5b23216.png" width=70%>
  
   1.4 Subscribe<p>
   "subscribe: tagID1, tagID2, ..." - Add monitored tags to DA server and receive updates when new values are available<p>

   JSON returns {"DA":[{"i": "tagID1", "v": "20.308", "t": 1643759756112, "q": 192}, {"i": "tagID2", "v": "4", "t": 1643769859342, "q": 192}, ...]}<br>(i - ID, v - value, t - time stamp in milliseconds of epoch UTC, q - quality)<p>
   When command "subscribe:Saw-toothed Waves.Int1,Saw-toothed Waves.Int2" is sent, response will be like<p>
   <img src="https://user-images.githubusercontent.com/13662339/210925641-7eea7071-05e7-4c13-a9ef-527aa38e79da.png" width=70%>

   1.5 Unsubscribe<p>
   "unsubscribe" - Remove all monitored tags from DA server<p>
   "unsubscribe: tagID1, tagID2, ..." - Remove specific monitored tags from DA server<p>
   
2. HDA commands<p>
2.1 Browse<p>
  "browseHDA" - Show all child tags under top level of HDA server<p>
  "browseHDA:tagID" - Show all child tags under a specific tag of HDA server<p>
  "browseHDA:tagID -countsInPagenation -pageNumber" - Show a subset of children tags based on pagenation for a specific tag in HDA server. For example, if there are total 10,000 children tags under a specific tag, command "browseHDA: tagID -2000 -3" will only display a tag's 2000 children tags (4000th to 5999th) for 3rd page in HDA server.<p> 
  JSON returns {"parentNodeID":[{"n": "tagName1", "i": "tagID1", "b": 1}, {"n": "tagName2", "i": "tagID2", "b": 0}, ...]}<br>(parentNodeID - parent node id or "" at top level, n - name, i - ID, b - branch)<p>
  When command "browseHDA: Random" is sent, response will be like<p><img src="https://user-images.githubusercontent.com/13662339/198896314-9b2dd8cb-6d62-4c78-9aaa-e4dbe4df2a46.png" width=70%><p>
  2.2 ReadRaw<p>
   "readRaw: tagID1, tagID2,..., tagIDx -startTimeStamp -endTimeStamp" - Read tags' history raw data based on start and end time stamps<p>
  
   JSON returns {"HDA":[{"tagID1":[{"v":"24201","t":1665632091123,"q":262336}, {"v":"19168","t":1665632092334,"q":262336},...]}, {"tagID2":[{"v":"24","t":1665632091445,"q":262336}, {"v":"168","t":1665632092667,"q":262336},...]}]}<br>(v - value, t - time stamp in milliseconds of epoch UTC, q - quality which need be parsed with OPC HDA and DA masks to have results like Raw/Interpolated and Good/Bad)<p>
   When command "readRaw: Saw-toothed Waves.Int1,Saw-toothed Waves.Int2 -1672977528112 -1672977529338" is sent, response will be like<p>
   <img src="https://user-images.githubusercontent.com/13662339/210927710-843e6bb5-47c1-4d6b-a63b-5c6a384c1359.png" width=70%><p>

   2.3 ReadAtTime<p>
   "readAtTime: tagID1, tagID2, ..., tagIDx -timeStamp1 -timsStamp2 -timeStampX" - Read tags' history data based on various time stamps<p>
   
   JSON returns {"HDA":[{"tagID1":[{"v":"24201","t":1665632091231,"q":262336}, {"v":"19168","t":1665632092354,"q":262336},...]}, {"tagID2":[{"v":"24","t":1665632091341,"q":262336}, {"v":"168","t":1665632092321,"q":262336},...]}]}<br>(v - value, t - time stamp in milliseconds of epoch UTC, q - quality which need be parsed with OPC HDA and DA masks to have results like Raw/Interpolated and Good/Bad)<p>
   
   When command "readAtTime: Saw-toothed Waves.Int1,Saw-toothed Waves.Int2 -1672978265112 -1672978266338" is sent, response will be like<p>
   <img src="https://user-images.githubusercontent.com/13662339/210928806-418d44af-c09f-4819-a27b-50450af92e00.png" width=70%><p>

   2.4 readModified<p>
   "readModified: tagID1, tagID2,..., tagIDx -startTimeStamp -endTimeStamp" - Read tags' modified history data based on start and end time stamps<p>
   
   JSON returns {"HDA":[{"tagID1":[{"v":"24201","t":1665632091231,"q":262336}, {"v":"19168","t":1665632092354,"q":262336},...]}, {"tagID2":[{"v":"24","t":1665632091341,"q":262336}, {"v":"168","t":1665632092321,"q":262336},...]}]}<br>(v - value, t - time stamp in milliseconds of epoch UTC, q - quality which need be parsed with OPC HDA and DA masks to have results like Raw/Interpolated and Good/Bad)<p>

   2.5 ReadProcessed<p>
   "readProcessed: tagID1, tagID2,..., tagIDx -startTimeStamp -endTimeStamp -intervalInMilliseconds -aggregate" - Read tags' history processed data based on start and end time stamps at a given interval for an aggregate method from the list below(vendor specific aggregate methods not shown)<p>
   ![image](https://github.com/user-attachments/assets/83a59ef4-5492-403c-9e9c-1e2b94ac3c28)

   JSON returns {"HDA":[{"tagID1":[{"v":"24201","t":1665632091231,"q":262336}, {"v":"19168","t":1665632092354,"q":262336},...]}, {"tagID2":[{"v":"24","t":1665632091341,"q":262336}, {"v":"168","t":1665632092321,"q":262336},...]}]}<br>(v - value, t - time stamp in milliseconds of epoch UTC, q - quality which need be parsed with OPC HDA and DA masks to have results like Raw/Interpolated and Good/Bad)<p>
   
   When command "readProcessed: random.Int1,random.Int4 -1705350325000 -1705350425000 -5000  -10" is sent, response will be like<p>
   <img src="https://github.com/duduyoyo/WebSocket4OPC/assets/13662339/87da231e-ea59-40bf-8706-8bb9185ced1e" width=70%><p>

    2.6 InsertReplace<p>
   "insertReplace: tagID1 -value -timeStamp -quality;tagID2 -value -timeStamp -quality;..." - Insert or replace tags' history data and quality for specific time stamps in epoch milliseconds<p>
   
   No JSON returns except an operation status message<p>
   
   When command "insertReplace: Bucket Brigade.Int1 -234 -1710719956000 -192; Bucket Brigade.Int4 -567 -1710720852000 -192" is sent, response will be like<p>
   <img src="https://github.com/duduyoyo/WebSocket4OPC/assets/13662339/d0dbe3ef-aad0-467a-97c9-9d40b4414709" width=70%><p>  

   2.7 DeleteAtTime<p>
   "deleteAtTime: tagID1, tagID2,..., tagIDX -timeStamp1 -timeStamp2 ... -timeStampX" - Delete tags' history data based on various time stamps in epoch milliseconds<p>
   
   No JSON returns except an operation status message<p>
   
   When command "deleteAtTime: Write Error.Int1, Bucket Brigade.Int1 -1713118247000 -1713116556000" is sent, response will be like<p>
   <img src="https://github.com/duduyoyo/WebSocket4OPC/assets/13662339/14734cd4-f60c-42f6-ab43-ceb74470020e" width=70%><p>
      
4. AE commands<p>
   3.1 Subscribe<p>
   "subscribeAE" - Receive notification on alarms and events<p>
   JSON returns {"AE":[{"s":"tagName1","m":"tagName1 Deviation is Low","c":"DEVIATION","sc":"LO","t":1643760803334,"q":192,"tp":4,"ec":2,"st":200,"a":1,"at":""}, {"s":"tagName2","m":"tagName2 Limit is Normal","c":"PVLEVEL","sc":"HIHI","t":1643760808112,"q":192,"tp":4,"ec":1,"st":500,"a":1,"at":""}]}<br>(s - source, m - message, c - condition, sc - sub condition, t - time stamp in milliseconds of epoch UTC, q - quality, tp - type, ec - category, st - severity, a - acknowledgement, at - actor)<p>
   When command "subscribeAE" is sent, response will be like<p>
   <img src="https://user-images.githubusercontent.com/13662339/210926438-3cd533e3-a4d7-40e0-85c9-2e53ad57b11c.png" width=70%><p>
   3.2 Unsubscribe<p>
   "unsubscribeAE" - Remove notification on alarms and events<p>
   
5. Disconnect<p>
   "disconnect" - Close connection with server<p>
         
6. Help<p>
   "help" or "?" - Display all supported commands and usages<p>
         
<h2>Sample code output</h2>
Sample codes for different languages (Python/Swift/C#/C++/Java) are available in client folder<br>

<h4>Python</h4>
<img src="https://user-images.githubusercontent.com/13662339/211084178-425cd4b3-3c85-43a2-92d3-afc6f098e097.png" width=70%>

<h4>Swift</h4>


<div style="display: table">


https://user-images.githubusercontent.com/13662339/200226922-060a4473-e3ec-4900-840d-5ccd4404fb10.mp4


<img width=30% src="https://user-images.githubusercontent.com/13662339/200226063-9657a8d7-6c40-4a0c-a2a4-f79b2a1825c6.PNG">
<img width=30% src="https://user-images.githubusercontent.com/13662339/200226217-cd01d396-355b-4699-bd8e-f25dc3649ea0.PNG">
<img width=30% src="https://user-images.githubusercontent.com/13662339/200226289-1ed0c8bf-570f-4e30-b744-d0442b86d072.PNG">
<img width=30% src="https://user-images.githubusercontent.com/13662339/200226340-732b7bf4-b5e7-4a94-9167-2b78b06cfcd0.PNG">

</div>

<h4>C#</h4>
<img src="https://user-images.githubusercontent.com/13662339/211069095-c149e1d5-74a8-4ceb-a9a6-cf8740adb1ae.png" width=70%>

<h4>C++</h4>
<img src="https://user-images.githubusercontent.com/13662339/211079056-a3356a02-a9b1-4cb5-95fb-c67e9ad0a539.png" width=70%>

<h4>Java</h4>
<img src="https://user-images.githubusercontent.com/13662339/211081301-6a2e0475-383f-43d4-9fff-a66a9a094c04.png" width=70%>

<h2>Roadmap</h2>
- Full-fledged open source native client for iOS and partners/contributors are welcome<br>

<h2>Related contribution</h2>
<a href="https://github.com/duduyoyo/OLEDB4OPC">OLEDB4OPC</a>, the fastest way to transfer OPC data to database!
