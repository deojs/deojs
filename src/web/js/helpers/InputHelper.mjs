import FileLoader from "../workers/FileLoader.worker.js";

/**
 * Helper for managing and loading inputs
 */
class InputHelper {
    constructor(App) {
        this.App = App;
        this.FileLoader = null;
        this.fileQueue = [];
        this.loadingFile = false;
        this.callbacks = {};
        this.currentId = 0;
    }

    /**
     * Stores a callback function
     *
     * @param {object} cb Callback
     * @returns {number} - Callback ID
     */
    addCallback(cb) {
        const id = this.currentId;
        this.currentId += 1;
        this.callbacks[id] = cb;
        return id;
    }

    /**
     * Sends file to be loaded to the FileLoader.
     * If FileLoader is currently loading a file, instead queue the file
     *
     * @param {File} file The file object to be loaded
     * @param {object} cb Callback for when the file has finished loading
     * @returns {object} File object containing the file and id
     */
    loadFile(file, cb) {
        const fileObj = {
            file: file,
            id: this.addCallback(cb)
        };
        if (this.loadingFile) {
            this.fileQueue.push(fileObj);
        } else {
            this.loadNextFile(fileObj);
        }
        return fileObj;
    }

    /**
     * Sends the fileObj object to the FileLoader worker
     *
     * @param {object} fileObj - The object to be sent to the FileLoader
     * @param {File} fileObj.file - The file object to be loaded
     * @param {number} fileObj.id - The ID of this file
     */
    loadNextFile(fileObj) {
        if (fileObj.file === undefined) {
            throw Error("fileObj parameter value doesn't have a file property.");
        }
        if (fileObj.id === undefined) {
            throw Error("fileObj parameter value doesn't have an id property.");
        }

        if (this.FileLoader === null) {
            this.createFileLoader();
        }
        this.FileLoader.postMessage({ command: "loadFile", data: fileObj });
    }

    /**
     * Creates a new FileLoader
     */
    createFileLoader() {
        if (this.FileLoader !== null) {
            // Tell current FileLoader to exit (cancels any ongoing loads)
            this.FileLoader.postMessage({ command: "exit" });
        }
        this.FileLoader = new FileLoader();
        this.FileLoader.addEventListener("message", this.handleLoaderMessage.bind(this));
    }

    /**
     * Handle messages sent by the FileLoader
     *
     * @param {MessageEvent} e - The message object
     */
    handleLoaderMessage(e) {
        if (!e.data) return;
        const message = e.data;
        switch (message.command) {
        case "progress":
            console.log(`File ID ${message.data.id} load progress: ${message.data.loaded}/${message.data.total}`);
            break;
        case "fileLoaded":
            this.fileLoaded(message.data);
            break;
        case "error":
            this.handleLoaderError(message.data);
            break;
        default:
            console.log(message);
            console.warn(`Invalid command ${message.command}`);
        }
    }

    /**
     * Fires when a file finsihes loading
     *
     * @param {object} data - The returned data object
     */
    fileLoaded(data) {
        console.log(`File ID ${data.id} loaded.`);
        this.callbacks[data.id](data.data, false);
    }

    /**
     * Handles errors sent back by the FileLoader
     *
     * @param {object} data - Message data
     */
    handleLoaderError(data) {
        console.error(`Error loading file ${data.id}: ${data.data}`);
        this.callbacks[data.id](new ArrayBuffer(), true);
    }

    /**
     * Requests decoded data from the inputWorker
     *
     * @param {string} encoding - The encoding type to use, defaults to "utf-8"
     * @returns {string} - The decoded data
     */
    getDecodedData(encoding = "utf-8") {
        return new Promise((resolve, reject) => {
            const callbackid = this.App.addCallback(resolve);
            this.App.InputWorker.postMessage({
                command: "getDecodedData",
                data: {
                    callbackid: callbackid,
                    encoding: encoding
                }
            });
        });
    }

    /**
     * Requests raw data from the inputWorker
     *
     * @returns {ArrayBuffer} - The raw data
     */
    async getRawData() {
        return new Promise((resolve, reject) => {
            const callbackid = this.App.addCallback(resolve);
            this.App.InputWorker.postMessage({
                command: "getRawData",
                data: {
                    callbackid: callbackid
                }
            });
        });
    }
}

export default InputHelper;
