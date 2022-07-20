# WebSocket4OPC
Enable WebSocket in OPC DA/AE Server with JSON return, first time ever

How did this idea come from?

DCOM was developed more than 2 decades ago and that was the technology classic OPC started with. Young kids get out of school with dynamic languages on hand. They care about writing a few line scripts to bring data back rather than knowing how it happens under hood, and it is anti-intuitive to get their feet wet on this legacy. With the adoption of WebSocket everywhere it is time to introspect how to combine this new technology with old DCOM.
The solution, WebSocket4OPC, is such an exploration. It utilizes WebSocket in IIS to communicate with OPC server and wraps all dirty work in simple JSON return. This solution gets rid of DCOM completely since IIS and OPC servers are hosted in the same one. 

<h3>Benefits</h3>

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
