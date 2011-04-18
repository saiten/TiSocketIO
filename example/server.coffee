http = require('http')
io = require('socket.io')

server = http.createServer (req, res) ->
  res.writeHead(200, { 'Content-Type': 'text/html' })
  res.end '''
    <html>
      <head><title>test</title></head>
    <body>
    <h1>test server</h1>
    <textarea id="chat" rows=10 cols="80"></textarea><br/>
    <form id="form">
      <input type="text" id="input" value="" /><input type="submit" value="send" />
    </form>
    <script type="text/javascript" src="/socket.io/socket.io.js"></script>
    <script type="text/javascript">
      var socket = new io.Socket();
      var textArea = document.getElementById('chat');
      var log = function(message) { textArea.value += message + "\\n" };
      var form = document.getElementById('form');
      var input = document.getElementById('input');

      form.addEventListener('submit', function(e) {
        e.preventDefault();
        if(input.value.length > 0) {
          if(input.value == 'exit') {
            socket.disconnect();
          } else {
            socket.send(input.value);
            input.value = "";
          }
        }
        return false;
      });

      socket.connect();
      socket.on("connect", function() {
        log("> connect");
        log("type 'exit' for disconnect")
      });
      socket.on("message", function(message) {
        log(message);
      });
      socket.on("disconnect", function() {
        log("> disconnect");
      });
    </script>
    </body>
    </html>
  '''

server.listen(3000)

socket = io.listen(server)
count = 0
socket.on 'connection', (client) ->
  count += 1

  client.broadcast "join user : #{count}"
  client.send "join : #{count}"

  client.on 'message', (data) ->
    message = "#{client.sessionId} : #{data}"
    client.broadcast message
    client.send message

  client.on 'disconnect', (data) ->
    count -= 1
    client.broadcast "leave user : #{count}"

