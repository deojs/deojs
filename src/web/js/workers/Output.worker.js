/**
 * Worker to handle storage and processing of output
 */

import hljs from "highlight.js";

// Object containing the output data and information
self.output = {};

/**
 * Handle messages sent by the main thread
 */
self.addEventListener("message", (e) => {
    if (!e.data) return;
    const data = e.data;

    if (!data.command) return;
    switch (data.command) {
    case "updateOutput":
        self.updateOutput(data.data);
        break;
    case "getOutput":
        self.postMessage({
            command: "callback",
            data: {
                callbackid: data.data.callbackid,
                data: self.getOutput(data.data.highlight)
            }
        });
        break;
    default:
        console.error(`Invalid command "${data.command}"`);
    }
});

/**
 * Updates the output object to contain the updated output
 *
 * @param {object} output - The new output data
 */
self.updateOutput = function (output) {
    self.output = output;
};

/**
 * Retrieves the output, with optional syntax highlighting
 *
 * @param {boolean} highlight - If true, will apply syntax highlighting
 * @returns {string} - Either the normal output or a highlighted version
 */
self.getOutput = function (highlight) {
    if (!self.output.output) {
        return "";
    }
    if (highlight) {
        return hljs.highlight(self.output.language, self.output.output).value;
    }

    return self.output.output;
};
