import "phoenix_html"
import {Socket, Presence} from "phoenix"

var socket;
const guzell = window.localStorage.getItem('user');
if (guzell) {
  socket = new Socket("/socket", {params: {user: guzell}})
  socket.connect()
}
else {
  const name = prompt('Anna nimi!!!')
  socket = new Socket("/socket", {params: {user: name}})
  window.localStorage.setItem('user', name);
  socket.connect()
}



let presences = {}


let formatTimestamp = (timestamp) => {
  let date = new Date(timestamp)
  return date.toLocaleTimeString()
}
let listBy = (user, {metas: metas}) => {
  return {
    user: user,
    onlineAt: formatTimestamp(metas[0].online_at)
  }
}

let userList = document.getElementById("UserList")
let render = (presences) => {
  userList.innerHTML = Presence.list(presences, listBy)
    .map(presence => `
      <li>
        ${presence.user}
        <br>
        <small>online since ${presence.onlineAt}</small>
      </li>
    `)
    .join("")
}

// Channels
let room = socket.channel("room:lobby")
room.on("presence_state", state => {
  presences = Presence.syncState(presences, state)
  render(presences)
})

room.on("presence_diff", diff => {
  presences = Presence.syncDiff(presences, diff)
  render(presences)
})

room.join()

// web/static/js/app.js
let messageInput = document.getElementById("NewMessage")
messageInput.addEventListener("keypress", (e) => {
  if (e.keyCode == 13 && messageInput.value != "") {
    room.push("message:new", messageInput.value)
    messageInput.value = ""
  }
})

let messageList = document.getElementById("MessageList")
let renderMessage = (message) => {
  let messageElement = document.createElement("li")
  messageElement.innerHTML = `
    <b>${message.user}</b>
    <i>${formatTimestamp(message.timestamp)}</i>
    <p>${message.body}</p>
  `
  messageList.appendChild(messageElement)
  messageList.scrollTop = messageList.scrollHeight;
}
let renderMessages = (messageList) => {
    console.log(messageList.history);
  messageList.history.forEach((x) => renderMessage(x));
}

room.on("message:new", message => renderMessage(message))
room.on("message:history", message_list => renderMessages(message_list))
