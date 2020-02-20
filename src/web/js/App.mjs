/**
 * Main handler for the App and UI
 */
import AppWorker from "./workers/App.worker.js";
import UIHelper from "./helpers/UIHelper.mjs";
import InputHelper from "./helpers/InputHelper.mjs";

class App {
    setupHelpers() {
        this.UIHelper = new UIHelper(this);
        this.InputHelper = new InputHelper(this);

        this.UIHelper.setupUI();
    }

    setupWorkers() {
        this.AppWorker = new AppWorker();
    }

    init() {
        this.setupHelpers();
        this.setupWorkers();
    }
}

export default App;
