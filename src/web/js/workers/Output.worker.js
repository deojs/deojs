/**
 * Worker to handle storage and processing of output
 */

import hljs from "highlight.js";

// Object containing the output data and information
self.outputs = [];

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
                data: self.getOutput(data.data.outputNum, data.data.highlight)
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
    self.outputs = output;
};

/**
 * Retrieves the output, with optional syntax highlighting
 *
 * @param {number} outputNum - The index of the output to get. -1 will get the final output
 * @param {boolean} highlight - If true, will apply syntax highlighting
 * @returns {string} - Either the normal output or a highlighted version
 */
self.getOutput = function (outputNum, highlight) {
    if (outputNum === -1) outputNum = (self.outputs.length - 1);
    if (!self.outputs[outputNum]
        || !self.outputs[outputNum].opOutputString) {
        return {
            output: "",
            parses: false
        };
    }
    if (highlight) {
        let parses = true;
        if (!Object.prototype.hasOwnProperty.call(self.outputs[outputNum].opOutputAST, "data")) {
            parses = false;
        }
        return {
            output: hljs.highlight(self.outputs[outputNum].language, self.outputs[outputNum].opOutputString).value,
            parses: parses
        };
    }

    return self.output.output;
};
