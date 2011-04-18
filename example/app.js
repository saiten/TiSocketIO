(function() {
  var io, log, socket, textArea, textField, win;
  win = Ti.UI.createWindow({
    backgroundColor: 'white'
  });
  textArea = Ti.UI.createTextArea({
    top: 10,
    width: 300,
    height: 180,
    backgroundColor: '#ddd',
    borderColor: '#888',
    borderWidth: 1,
    borderRadius: 5,
    editable: false,
    value: ""
  });
  log = function(message) {
    var v;
    v = textArea.value;
    return textArea.value = v + ("" + message + "\n");
  };
  textField = Ti.UI.createTextField({
    top: 200,
    width: 300,
    height: 32,
    borderStyle: Ti.UI.INPUT_BORDERSTYLE_BEZEL,
    returnKeyType: Ti.UI.RETURNKEY_SEND,
    clearButtonMode: Ti.UI.INPUT_BUTTONMODE_ONFOCUS,
    suppressReturn: false
  });
  io = require('co.saiten.ti.socket.io');
  socket = io.createSocket('localhost', 3000);
  socket.addEventListener('connect', function(client) {
    log("> connect");
    return log("type 'exit' for disconnect");
  });
  socket.addEventListener('disconnect', function(client) {
    log("> disconnect");
    return log("type 'connect' for reconnect");
  });
  socket.addEventListener('message', function(e) {
    return log(e.message);
  });
  win.addEventListener('open', function() {
    textField.focus();
    return socket.connect();
  });
  textField.addEventListener('return', function(e) {
    if (!(e.value.length > 0)) {
      return;
    }
    if (socket.isConnected) {
      if (e.value === 'exit') {
        socket.disconnect();
      } else {
        socket.send(textField.value, false);
      }
    } else if (e.value === 'connect') {
      socket.connect();
    }
    return textField.value = "";
  });
  win.add(textArea);
  win.add(textField);
  win.open();
}).call(this);
