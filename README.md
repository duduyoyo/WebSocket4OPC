# WebSocket4OPC
Enable WebSocket in OPC DA/AE/HDA Server with JSON response - the FIRST TIME ever!

COM/DCOM was developed over two decades ago and served as the foundation for classic OPC servers. However, modern developers increasingly favor dynamic languages like Python and JavaScript for their simplicity and productivity, as opposed to the steep learning curve of COM/DCOM programming. Fortunately, with the widespread adoption of WebSocket across modern programming languages, it's now possible to bridge the gap between dynamic languages and legacy COM/DCOM technologies.<p>
This innovative solution offers the best of all worlds by combining the strengths of its technology stack:<p>
    1. WebSocket — a standardized network protocol enabling cross-platform, full-duplex communication<br>
    2. Microsoft IIS — providing robust support for authorization, authentication, firewalls, certificates, and encryption<br>
    3. Classic OPC Servers — the most widely adopted standard in the industrial automation sector<p>
Without the complexity, rigidity, and overhead of OPC UA, plant data can be delivered easily, securely, and reliably with this solution — whether on a desktop or mobile device.<p>
Say goodbye to COM/DCOM — and Hello to the world's only all-in-one solution for accessing OPC DA/AE/HDA Data in your preferred language!

<h2>Benefits</h2>

.Fully support Python/JavaScript/Java/C#/C++/Swift etc — No OPC UA, No SDKs, No Hassles<br>
.No COM/DCOM vulnerabilities or hardening concerns<br>
.Built-in user authentication and authorization via IIS<br>
.Secure connections with certificate-based HTTPS provided by IIS<br>
.Data encryption handled by IIS for secure transmission<br>
.Guaranteed cross-platform client support (Linux, Mac, Windows)<br>
.No costly OPC corporate membership fees<br>
.Simple, intuitive commands — no need for long REST API URLs<br>
.Native mobile app development fully supported<br>
.No need to read through 1,250 pages of OPC UA documentation<br>
.No OPC UA certificate setup required<br>
.No OPC UA firewall configuration needed<br>
.No need to convert OPC DA to OPC UA, purely plant data delivered<br>
.Ready for edge or gateway deployment - locally or remotely, no expensive custom hardware needed<br>

<h2>Pre-requiste</h2>
1. Install on the same server where classic OPC DA/AE/HDA server is running<br>
2. Microsoft VC++ Runtim for X64 is required (download and install it <a href="https://aka.ms/vs/17/release/vc_redist.x64.exe">here</a> if not already present)<br>
3. Ensure the WebSocket feature is enabled in IIS on the same server<br>
<img src="https://github.com/user-attachments/assets/2f6bf591-42e3-4dd8-a41f-5e8b122ba1a9" width=30%>

<h2>Installation</h2>

Download all files from the server folder to your desired location. Open a command prompt with administrator privileges and navigate to your download folder. Run the command:<p>
install.bat userAccount userPassword<p>
Replace userAccount and userPassword with your own Windows credentials, ensuring the account has administrator privileges. These credentials are used only by IIS to configure a new application pool — they are neither stored nor used by this solution for any other purpose.

To verify the installation, open a browser (Chrome, Safari, or Edge) and navigate to the following URL: "http://localhost/OPC/websocket.html"<p>
<img src="https://user-images.githubusercontent.com/13662339/199052370-58d084ef-170e-4d40-87d0-295766d36b43.png" width=70%>

If installed in a multi-server environment, a configuration file located in the ProgramData folder allows you to specify the desired server using its ProgID.<p>

<h2>Uninstallation</h2>
Run the uninstall.bat command in a Command Prompt with administrator privileges from your download folder.

<h2>Usage</h2><p>
      
1. DA commands<p>
1.1 Browse<p>
   "browse" - Display all child tags at the top level of the DA server<p>
   "browse:tagID" - Display all child tags under a specific tag of the DA server<p>
   "browse:tagID -countsInPagenation -pageNumber" - Display a paginated subset of child tags under a specific tag in the DA server. For example, if there are 10,000 child tags under a specific tag, the command "browse: tagID -2000 -3" will display only 2,000 child tags (from the 4,000th to the 5,999th) corresponding to page 3 in the DA server<p>
    
   JSON returns {"parentNodeID":[{"n": "tagName1", "i": "tagID1", "b": 1}, {"n": "tagName2", "i": "tagID2", "b": 0}, ...]}<br>(parentNodeID - parent node id or "" at top level, n - name, i - ID, b - branch)<p>
    When command "browse: Random" is sent, response will be like<p>
    <img src="https://user-images.githubusercontent.com/13662339/193419607-97d11de8-4116-4b0e-a767-e8c810c4ce01.png" width=70%><p>
1.2 Read<p> 
   "read: tagID1, tagID2, ..."- Read the latest values of tags from the DA server<p>

   JSON returns {"DA":[{"i": "tagID1", "v": "20.308", "t": 1643759756112, "q": 192}, {"i": "tagID2", "v": "4", "t": 1643769859342, "q": 192}, ...]}<br>(i - ID, v - value, t - time stamp in milliseconds of epoch UTC, q - quality)<p>
   When command "read: Random.Real4, Random.Int2" is sent, response will be like<p>
   <img src="https://user-images.githubusercontent.com/13662339/216796465-f2822c20-9ca2-42f6-8e14-c5ce848e43bf.png" width=70%>  
  
   1.3 Write<p>
   "write: tagID1 -value1; tagID2 -value2; ..." - Write tag values to the DA server. It is strongly recommended not to use this command in a production environment with Internet access. Please contact the developer to obtain a production version without this command.<p>

   No JSON return but writing status (success/failure) will be reported as info. Use read command to verify writing's success<p>
   When command "write: Bucket Brigade.Int2 -34; Random.Int2 -12" is sent, response will be like<p>
   <img src="https://user-images.githubusercontent.com/13662339/232327090-7744a9be-3300-4b00-a6f7-e7c2f5b23216.png" width=70%>
  
   1.4 Subscribe<p>
   "subscribe: tagID1, tagID2, ..." - Add tags to be monitored on the DA server and receive updates whenever new values are available<p>

   JSON returns {"DA":[{"i": "tagID1", "v": "20.308", "t": 1643759756112, "q": 192}, {"i": "tagID2", "v": "4", "t": 1643769859342, "q": 192}, ...]}<br>(i - ID, v - value, t - time stamp in milliseconds of epoch UTC, q - quality)<p>
   When command "subscribe:Saw-toothed Waves.Int1,Saw-toothed Waves.Int2" is sent, response will be like<p>
   <img src="https://user-images.githubusercontent.com/13662339/210925641-7eea7071-05e7-4c13-a9ef-527aa38e79da.png" width=70%>

   1.5 Unsubscribe<p>
   "unsubscribe" - Remove all monitored tags from the DA server<p>
   "unsubscribe: tagID1, tagID2, ..." - Remove the specific monitored tags from the DA server<p>
   
2. HDA commands<p>
2.1 Browse<p>
  "browseHDA" - Display all child tags at the top level of the HDA server<p>
  "browseHDA:tagID" - Display all child tags under a specific tag in the HDA server<p>
  "browseHDA:tagID -countsInPagenation -pageNumber" - Display a paginated subset of child tags for a specific tag in the HDA server. For example, if there are a total of 10,000 child tags under a specific tag, the command "browseHDA: tagID -2000 -3" will display 2,000 child tags (from the 4,000th to the 5,999th) corresponding to the 3rd page in the HDA server.<p>

  JSON returns {"parentNodeID":[{"n": "tagName1", "i": "tagID1", "b": 1}, {"n": "tagName2", "i": "tagID2", "b": 0}, ...]}<br>(parentNodeID - parent node id or "" at top level, n - name, i - ID, b - branch)<p>
  When command "browseHDA: Random" is sent, response will be like<p><img src="https://user-images.githubusercontent.com/13662339/198896314-9b2dd8cb-6d62-4c78-9aaa-e4dbe4df2a46.png" width=70%><p>
  2.2 ReadRaw<p>
   "readRaw: tagID1, tagID2,..., tagIDx -startTimeStamp -endTimeStamp" - Read historical raw data of tags based on specified start and end timestamps<p>
  
   JSON returns {"HDA":[{"tagID1":[{"v":"24201","t":1665632091123,"q":262336}, {"v":"19168","t":1665632092334,"q":262336},...]}, {"tagID2":[{"v":"24","t":1665632091445,"q":262336}, {"v":"168","t":1665632092667,"q":262336},...]}]}<br>(v - value, t - time stamp in milliseconds of epoch UTC, q - quality which need be parsed with OPC HDA and DA masks to have results like Raw/Interpolated and Good/Bad)<p>
   When command "readRaw: Saw-toothed Waves.Int1,Saw-toothed Waves.Int2 -1672977528112 -1672977529338" is sent, response will be like<p>
   <img src="https://user-images.githubusercontent.com/13662339/210927710-843e6bb5-47c1-4d6b-a63b-5c6a384c1359.png" width=70%><p>

   2.3 ReadAtTime<p>
   "readAtTime: tagID1, tagID2, ..., tagIDx -timeStamp1 -timsStamp2 -timeStampX" - Read historical tags' values based on various timestamps<p>
   
   JSON returns {"HDA":[{"tagID1":[{"v":"24201","t":1665632091231,"q":262336}, {"v":"19168","t":1665632092354,"q":262336},...]}, {"tagID2":[{"v":"24","t":1665632091341,"q":262336}, {"v":"168","t":1665632092321,"q":262336},...]}]}<br>(v - value, t - time stamp in milliseconds of epoch UTC, q - quality which need be parsed with OPC HDA and DA masks to have results like Raw/Interpolated and Good/Bad)<p>
   
   When command "readAtTime: Saw-toothed Waves.Int1,Saw-toothed Waves.Int2 -1672978265112 -1672978266338" is sent, response will be like<p>
   <img src="https://user-images.githubusercontent.com/13662339/210928806-418d44af-c09f-4819-a27b-50450af92e00.png" width=70%><p>

   2.4 ReadModified<p>
   "readModified: tagID1, tagID2,..., tagIDx -startTimeStamp -endTimeStamp" - Read tags' modified historical values based on specified start and end timestamps<p>
   
   JSON returns {"HDA":[{"tagID1":[{"v":"24201","t":1665632091231,"q":262336}, {"v":"19168","t":1665632092354,"q":262336},...]}, {"tagID2":[{"v":"24","t":1665632091341,"q":262336}, {"v":"168","t":1665632092321,"q":262336},...]}]}<br>(v - value, t - time stamp in milliseconds of epoch UTC, q - quality which need be parsed with OPC HDA and DA masks to have results like Raw/Interpolated and Good/Bad)<p>

   2.5 ReadProcessed<p>
   "readProcessed: tagID1, tagID2,..., tagIDx -startTimeStamp -endTimeStamp -intervalInMilliseconds -aggregate" - Read tags' processed historical values based on specified start and end timestamps, using a defined interval and one of the aggregate methods listed below (vendor-specific methods not included)<p>
<img src="https://github.com/user-attachments/assets/83a59ef4-5492-403c-9e9c-1e2b94ac3c28" width=40%>

   JSON returns {"HDA":[{"tagID1":[{"v":"24201","t":1665632091231,"q":262336}, {"v":"19168","t":1665632092354,"q":262336},...]}, {"tagID2":[{"v":"24","t":1665632091341,"q":262336}, {"v":"168","t":1665632092321,"q":262336},...]}]}<br>(v - value, t - time stamp in milliseconds of epoch UTC, q - quality which need be parsed with OPC HDA and DA masks to have results like Raw/Interpolated and Good/Bad)<p>
   
   When command "readProcessed: random.Int1,random.Int4 -1705350325000 -1705350425000 -5000  -10" is sent, response will be like<p>
   <img src="https://github.com/duduyoyo/WebSocket4OPC/assets/13662339/87da231e-ea59-40bf-8706-8bb9185ced1e" width=70%>

    2.6 InsertReplace<p>
   "insertReplace: tagID1 -value -timeStamp -quality;tagID2 -value -timeStamp -quality;..." - Insert or replace tag historical data and quality values at specific timestamps (in epoch milliseconds)<p>
   
   No JSON returns except an operation status message<p>
   
   When command "insertReplace: Bucket Brigade.Int1 -234 -1710719956000 -192; Bucket Brigade.Int4 -567 -1710720852000 -192" is sent, response will be like<p>
   <img src="https://github.com/duduyoyo/WebSocket4OPC/assets/13662339/d0dbe3ef-aad0-467a-97c9-9d40b4414709" width=70%><p>  

   2.7 DeleteAtTime<p>
   "deleteAtTime: tagID1, tagID2,..., tagIDX -timeStamp1 -timeStamp2 ... -timeStampX" - Delete tags' historical values based on specified timestamps (in epoch milliseconds)<p>
   
   No JSON returns except an operation status message<p>
   
   When command "deleteAtTime: Write Error.Int1, Bucket Brigade.Int1 -1713118247000 -1713116556000" is sent, response will be like<p>
   <img src="https://github.com/duduyoyo/WebSocket4OPC/assets/13662339/14734cd4-f60c-42f6-ab43-ceb74470020e" width=70%><p>
      
3. AE commands<p>
   3.1 Subscribe<p>
   "subscribeAE" - Receive notifications for alarms and events<p>
   JSON returns {"AE":[{"s":"tagName1","m":"tagName1 Deviation is Low","c":"DEVIATION","sc":"LO","t":1643760803334,"q":192,"tp":4,"ec":2,"st":200,"a":1,"at":""}, {"s":"tagName2","m":"tagName2 Limit is Normal","c":"PVLEVEL","sc":"HIHI","t":1643760808112,"q":192,"tp":4,"ec":1,"st":500,"a":1,"at":""}]}<br>(s - source, m - message, c - condition, sc - sub condition, t - time stamp in milliseconds of epoch UTC, q - quality, tp - type, ec - category, st - severity, a - acknowledgement, at - actor)<p>
   When command "subscribeAE" is sent, response will be like<p>
   <img src="https://user-images.githubusercontent.com/13662339/210926438-3cd533e3-a4d7-40e0-85c9-2e53ad57b11c.png" width=70%><p>
   3.2 Unsubscribe<p>
   "unsubscribeAE" - Remove notifications for alarms and events<p>
   
4. Disconnect<p>
   "disconnect" - Close the connection to the server<p>
         
5. Help<p>
   "help" or "?" - Display all supported commands and their usage<p>
         
<h2>Sample code output</h2>
Sample code for various languages (Python, Swift, C#, C++, Java) is available in the client folder<br>

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

<h2>Service</h2>
- Consultation available for any edge design involving connections to OPC Classic servers<br>
- Customization available upon request<br>

<h2>Related contribution</h2>
<a href="https://github.com/duduyoyo/OLEDB4OPC">OLEDB4OPC</a>, the fastest way to transfer OPC data to database!<p>
<a href="https://github.com/duduyoyo/WebSocket4Fragment">WebSocket4Fragment</a>, a unique way to handle WebSocket fragment explicitly in run time!
