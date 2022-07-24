# WebSocket4OPC
Enable WebSocket in OPC DA/AE Server with JSON return, first time ever

DCOM was developed more than 2 decades ago and that was the technology classic OPC started with. Young kids get out of school with dynamic languages on hand. They care about writing a few line scripts to bring data back rather than knowing how it happens under hood, and it is anti-intuitive to get their feet wet on this legacy. With the adoption of WebSocket everywhere it is time to introspect how to combine this new technology with old DCOM.
The solution, WebSocket4OPC, is such an exploration. It utilizes WebSocket in IIS to communicate with OPC server and wraps all dirty work in simple JSON return. This solution gets rid of DCOM completely since IIS and OPC servers are hosted in the same one. 

<h2>Benefits</h2>

.No DCOM required to connect a classic OPC server, period<br>
.Dynamical languages (JavaScript, Python etc.) support<br>
.Return in JSON format<br>
.Intuitive and streamlined commands instead of long and difficult RESTful API<br>
.No worry about future DCOM vulnerability any more<br>
.Account authentication available<br>
.Secure connection available<br>
.Native mobile application made feasible<br>
.No thousand-page OPC UA document to read<br>
.No OPC UA certificate configuration required<br>
.No firewall configuration required<br>
.Edge connection ready<br>

<h2>Pre-requiste</h2>
1. Installation need be done in the same box of OPC DA/AE Server<br>
2. WebSocket feature for IIS need be enabled first<br>
3. Microsoft VC++ Runtim for X64 required (download <a href="https://aka.ms/vs/17/release/vc_redist.x64.exe">here</a> and install)<br>

<h2>Installation</h2>

To install, launch command line with administrator privilege. Go to folder where module is downloaded. Run command "install.bat myAccount myPassword". This credential will be used for app pool configuration.

To verify, launch browser (Chrome/Safari/Edge) and enter URL "http://localhost/OPC/websocket.html"<p>
<img src="https://user-images.githubusercontent.com/13662339/180631724-758611da-0cb2-4e24-baa3-98663d3a552e.png" width=70%>

<h2>Uninstallation</h2>
To uninstall, simply run command "uninstall.bat" in command line.

<h2>Usage</h2>

<h2>Screen shots of outputs for sample codes</h2>
