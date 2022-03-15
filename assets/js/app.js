// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Uploaders = {}
let Hooks = {}
Hooks.ToggleClass = {
  mounted() {
    this.el.addEventListener("click", this.toggleClass);
  },
  toggleClass(event) {
    let target = event.target
    let dataset = target.dataset

    document.querySelectorAll(event.target.dataset.target).forEach(el => {
      el.classList.toggle(dataset.class)

      if(target.innerText == dataset.textOff) {
        target.innerText = dataset.textOn
      } else {
        target.innerText = dataset.textOff
      }
    })
  },
}

Hooks.ContentEditable = {
  mounted() {
    this.el.contentEditable = true;
    this.el.addEventListener("blur", this.handleInput.bind(this));
  },
  handleInput(event) {
    let target = event.target
    let dataset = event.target.dataset

    dataset[dataset.attr] = target.innerText

    this.pushEvent(dataset.handleEvent, dataset, (reply, ref) => {
      if(reply.success == true) {
        target.classList.add("save-success")

        setTimeout((el) => {
          el.classList.remove("save-success")
        }, 500, target)
      } else {
        target.classList.add("save-failure")

        setTimeout((el) => {
          el.classList.remove("save-failure")
        }, 500, target)

        target.innerText = reply.errors.join(" ")
      }
    })
  }
}

window.addEventListener("phx:remove-class", event => {
  let target = event.target

  document.querySelectorAll(event.detail.selector).forEach(el => {
    el.classList.remove(event.detail.class)
  })
})

window.addEventListener("phx:add-class", event => {
  let target = event.target

  document.querySelectorAll(event.detail.selector).forEach(el => {
    el.classList.add(event.detail.class)
  })
})

window.addEventListener("phx:toggle-class", event => {
  let target = event.target

  document.querySelectorAll(event.detail.selector).forEach(el => {
    el.classList.toggle(event.detail.class)
  })
})

Uploaders.S3 = function(entries, onViewError) {
  entries.forEach(entry => {
    let formData = new FormData()
    let {url, fields} = entry.meta

    Object.entries(fields).forEach(([key, val]) => formData.append(key, val))

    formData.append("file", entry.file)

    let xhr = new XMLHttpRequest()

    onViewError(() => xhr.abort())

    xhr.onload = () => xhr.status === 204 ? entry.progress(100) : entry.error()
    xhr.onerror = () => entry.error()
    xhr.upload.addEventListener("progress", (event) => {
      if(event.lengthComputable) {
        let percent = Math.round((event.loaded / event.total) * 100)
        if(percent < 100) { entry.progress(percent) }
      }
    })

    xhr.open("POST", url, true)
    xhr.send(formData)
  })

}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, uploaders: Uploaders, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
