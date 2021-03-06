import OutputWorker from "../workers/Output.worker.js";

/**
 * Helper for managing outputs
 */
class OutputHelper {
    constructor(App) {
        this.App = App;
        this.callbacks = {};
        this.callbackId = 0;

        this.OutputWorker = new OutputWorker();
        this.OutputWorker.addEventListener("message", this.handleWorkerMessage.bind(this));
    }

    /**
     * Handles messages sent by the output worker
     *
     * @param {MessageEvent} message - The message sent by the worker
     */
    handleWorkerMessage(message) {
        if (!message.data) return;
        const data = message.data;

        if (!data.command) return;
        switch (data.command) {
        case "callback":
            this.fireCallback(data.data.callbackid, data.data.data);
            break;
        default:
            console.error(`Invalid command "${data.command}"`);
        }
    }

    /**
     * Clears the output
     */
    clearOutput() {
        document.getElementById("outputArea").innerHTML = "";
        this.OutputWorker.terminate();
        this.OutputWorker = new OutputWorker();
        this.OutputWorker.addEventListener("message", this.handleWorkerMessage.bind(this));
    }

    /**
     * Adds a new callback
     *
     * @param {Function} callback - The callback function
     * @returns {number} - The ID of the callback
     */
    addCallback(callback) {
        const id = this.callbackId;
        this.callbackId += 1;
        this.callbacks[id] = callback;
        return id;
    }

    /**
     * Fires a stored callback
     *
     * @param {number} callbackId - The ID of the callback to fire
     * @param {object} callbackData - The data to be sent to the callback
     */
    fireCallback(callbackId, callbackData) {
        this.callbacks[callbackId](callbackData);
    }

    /**
     * Updates the output stored in the OutputWorker
     *
     * @param {Array} outputValue - The new output values
     */
    updateOutput(outputValue) {
        this.OutputWorker.postMessage({
            command: "updateOutput",
            data: outputValue
        });
    }

    /**
     * Retrieves the current output from the OutputWorker
     *
     * @param {number} outputNum - The index of the output to get. -1 will get the final output
     * @param {boolean} highlight - If true, the returned output has syntax highlighting
     */
    async getOutput(outputNum, highlight) {
        return new Promise((resolve, reject) => {
            const callbackid = this.addCallback(resolve);
            this.OutputWorker.postMessage({
                command: "getOutput",
                data: {
                    callbackid: callbackid,
                    outputNum: outputNum,
                    highlight: highlight
                }
            });
        });
    }
}

export default OutputHelper;
