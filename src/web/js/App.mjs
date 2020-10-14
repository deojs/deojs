/**
 * Main handler for the App and UI
 */

import UIHelper from "./helpers/UIHelper.mjs";
import OutputHelper from "./helpers/OutputHelper.mjs";
import OperationHelper from "./helpers/OperationHelper.mjs";

import AppWorker from "./workers/App.worker.js";

class App {
    constructor() {
        this.setupHelpers();
        this.setupWorkers();
    }

    /**
     * Sets up the App helpers
     */
    setupHelpers() {
        this.UIHelper = new UIHelper(this);
        this.OutputHelper = new OutputHelper(this);
        this.OperationHelper = new OperationHelper(this);

        this.UIHelper.setupUI();
    }

    /**
     * Sets up the App workers (the AppWorker sets up more workers)
     */
    setupWorkers() {
        this.AppWorker = new AppWorker();
        this.AppWorker.addEventListener("message", this.handleAppWorkerMessage.bind(this));
        this.AppWorkerCallbacks = {};
        this.AppWorkerCallbackId = 0;
    }

    /**
     * Adds a new callback for the AppWorker
     *
     * @param {Function} cb - The callback function to add
     * @returns {number} - The ID of the callback added
     */
    addAppWorkerCallback(cb) {
        const id = this.AppWorkerCallbackId;
        this.AppWorkerCallbackId += 1;
        this.AppWorkerCallbacks[id] = cb;
        return id;
    }

    /**
     * Handles messages sent by the AppWorker
     *
     * @param {MessageEvent} message - The message sent from the AppWorker
     */
    handleAppWorkerMessage(message) {
        if (!message.data) return;
        const data = message.data;

        if (!data.command) return;
        const command = data.command;

        switch (command) {
        case "inputFileLoaded":
            this.UIHelper.inputFileLoaded(data.data.data, data.data.error);
            break;
        case "callback":
            this.AppWorkerCallbacks[data.data.callbackid](data.data.data);
            break;
        case "runcomplete":
            this.OperationHelper.runComplete(data.data.outputs, data.data.language);
            break;
        case "inputFileLoadProgress":
            this.UIHelper.updateInputProgress(data.data.loaded, data.data.total, "Loading");
            break;
        case "inputParseProgress":
            this.UIHelper.updateInputProgress(data.data.current, data.data.total, "Parsing");
            break;
        case "updateOpStatus":
            this.OperationHelper.updateOpStatus(data.data.opIndex, data.data.opName, data.data.status, data.data.tooltipText);
            break;
        default:
            console.error(`Invalid command "${command}"`);
        }
    }

    /**
     * Retrieves the input, decoded
     *
     * @param {string} encoding - The encoding to use, defaults to UTF-8
     * @returns {string} - The decoded input data
     */
    async getDecodedInput(encoding = "UTF-8") {
        return new Promise((resolve, reject) => {
            this.AppWorker.postMessage({
                command: "getDecodedInput",
                data: {
                    encoding: encoding,
                    callbackid: this.addAppWorkerCallback(resolve)
                }
            });
        });
    }
}

export default App;
