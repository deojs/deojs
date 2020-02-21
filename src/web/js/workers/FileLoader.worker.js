/**
 * Web worker for loading files from disk into memory
 */
self.addEventListener("message", (e) => {
    if (!e.data) return;

    const data = e.data;
    if (!data.command) return;

    switch (data.command) {
    case "loadFile":
        self.loadFile(data.data);
        break;
    case "exit":
        if (self.reader.readyState === 1) {
            self.reader.abort();
        }
        break;
    default:
        console.warn(`Invalid command "${data.command}"`);
    }
});

/**
 * Loads a file
 *
 * @param {object} fileObj
 */
self.loadFile = function (fileObj) {
    self.currentfile = {
        file: fileObj.file,
        id: fileObj.id
    };

    console.log(`Loading file (ID: ${self.currentfile.id}, Name: "${self.currentfile.file.name}", Size: ${self.currentfile.file.size}, MIME: ${self.currentfile.file.type})`);

    self.reader.readAsArrayBuffer(self.currentfile.file);
};

/**
 * Handles events fired by the FileReader
 *
 * @param {Event} event
 */
self.handleReaderEvent = function (event) {
    switch (event.type) {
    case "progress":
        self.sendProgress(event);
        break;
    case "load":
        self.sendResult(event);
        break;
    case "error":
        self.sendError();
        break;
    default:
        console.info(`Invalid event type ${event.type}.`);
    }
};

/**
 * Sends the file read progress back to the main thread
 *
 * @param {Event} event
 */
self.sendProgress = function (event) {
    self.postMessage({
        command: "progress",
        data: {
            id: self.currentfile.id,
            loaded: event.loaded,
            total: event.total
        }
    });
};

/**
 * Sends the loaded ArrayBuffer back to the main thread
 *
 * @param {Event} event
 */
self.sendResult = function (event) {
    if (!event.target) return;
    const target = event.target;

    self.postMessage({
        command: "fileLoaded",
        data: {
            id: self.currentfile.id,
            data: {
                file: self.currentfile,
                data: target.result
            }
        }
    }, [target.result]);

    self.currentfile = null;
};

/**
 * Sends the details of the error back to the main thread
 */
self.sendError = function () {
    self.postMessage({
        command: "error",
        data: {
            id: self.currentfile.id,
            data: self.reader.error
        }
    });
};

self.currentid = null;
self.reader = new FileReader();

self.reader.addEventListener("load", self.handleReaderEvent);
self.reader.addEventListener("error", self.handleReaderEvent);
self.reader.addEventListener("progress", self.handleReaderEvent);
