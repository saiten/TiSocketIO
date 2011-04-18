win = Ti.UI.createWindow
  backgroundColor: 'white'

textArea = Ti.UI.createTextArea
  top: 10
  width: 300
  height: 180
  backgroundColor: '#ddd'
  borderColor: '#888'
  borderWidth: 1
  borderRadius: 5
  editable: false
  value: ""

log = (message) ->
  v = textArea.value
  textArea.value = v + "#{message}\n"

textField = Ti.UI.createTextField
  top: 200
  width: 300
  height: 32
  borderStyle: Ti.UI.INPUT_BORDERSTYLE_BEZEL
  returnKeyType: Ti.UI.RETURNKEY_SEND
  clearButtonMode: Ti.UI.INPUT_BUTTONMODE_ONFOCUS
  suppressReturn: false

io = require('co.saiten.ti.socket.io')
socket = io.createSocket('localhost', 3000)

socket.addEventListener 'connect', (client) ->
  log("> connect")
  log("type 'exit' for disconnect")

socket.addEventListener 'disconnect', (client) ->
  log("> disconnect")
  log("type 'connect' for reconnect")

socket.addEventListener 'message', (e) ->
  log(e.message)

win.addEventListener 'open', ->
  textField.focus()
  socket.connect()

textField.addEventListener 'return', (e) ->
  return unless e.value.length > 0

  if socket.isConnected
    if e.value is 'exit'
      socket.disconnect()
    else
      socket.send textField.value, false
  else if e.value is 'connect'
    socket.connect()

  textField.value = ""

win.add textArea
win.add textField
win.open()

