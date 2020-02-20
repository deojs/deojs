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
     * Sends file to be loaded to the FileLoader.
     * If FileLoader is currently loading a file, instead queue the file
     *
     * @param {File} file The file object to be loaded
     * @param {object} cb Callback for when the file has finished loading
     */
    loadFile(file, cb) {
        const fileObj = {
            file: file,
            id: this.currentId += 1
        };
        this.callbacks[fileObj.id] = cb;
        if (this.loadingFile) {
            this.fileQueue.push(fileObj);
        } else {
            this.loadNextFile(fileObj);
        }
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
     * @param {MessageEvent} e
     */
    handleLoaderMessage(e) {
        if (!e.data) return;
        const message = e.data;
        switch (message.command) {
        case "progress":
            console.log(`File ID ${message.data.id} load progress: ${message.data.loaded}/${message.data.total}`);
            break;
        case "fileLoaded":
            console.log(`File ID ${message.data.id} loaded.`);
            break;
        default:
            console.log(message);
            console.warn(`Invalid command ${message.command}`);
        }
    }
}

export default InputHelper;
