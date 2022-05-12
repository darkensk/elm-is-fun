import { Elm } from "./Main.elm";

// Initialize Elm application inside div with id "root"
const app = Elm.Main.init({ node: document.getElementById("root") });

// 3.
// Subscribe to port for JS inter-ops
// Copy the string from Elm to clipboard
// app.ports.copyToClipboard.subscribe((sharedString) => {
//   console.log(sharedString);
//   navigator.clipboard.writeText(sharedString);
// });
