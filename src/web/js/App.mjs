/**
 * Main handler for the App and UI
 */

import UIHelper from "./helpers/UIHelper.mjs";
import InputHelper from "./helpers/InputHelper.mjs";
import OutputHelper from "./helpers/OutputHelper.mjs";

import AppWorker from "./workers/App.worker.js";
import InputWorker from "./workers/Input.worker.js";

class App {
    setupHelpers() {
        this.UIHelper = new UIHelper(this);
        this.InputHelper = new InputHelper(this);
        this.OutputHelper = new OutputHelper(this);

        this.UIHelper.setupUI();
    }

    setupWorkers() {
        this.AppWorker = new AppWorker();
        this.AppWorker.addEventListener("message", this.handleAppWorkerMessage.bind(this));
        this.AppWorkerCallbacks = {};
        this.AppWorkerCallbackId = 0;

        this.InputWorker = new InputWorker();
        this.InputWorker.addEventListener("message", this.handleInputWorkerMessage.bind(this));
        this.InputWorkerCallbacks = {};
        this.InputWorkerCallbackId = 0;
    }

    init() {
        this.setupHelpers();
        this.setupWorkers();
    }

    handleAppWorkerMessage(message) {
        console.log(message);
    }

    // These should be in the separate InputHelper (maybe including the entire inputworker)

    handleInputWorkerMessage(message) {
        if (!message.data) return;
        const data = message.data;

        if (!data.command) return;
        switch (data.command) {
        case "callback":
            this.InputWorkerCallbacks[data.data.callbackid](data.data.data);
            break;
        default:
            console.error(`Invalid command "${data.command}"`);
        }
    }

    addInputWorkerCallback(callback) {
        const id = this.InputWorkerCallbackId;
        this.InputWorkerCallbackId += 1;
        this.InputWorkerCallbacks[id] = callback;
        return id;
    }
}

export default App;
