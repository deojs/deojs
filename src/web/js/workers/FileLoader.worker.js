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
    const file = fileObj.file;
    self.currentid = fileObj.id;

    console.log(`Loading file (ID: ${self.currentid}, Name: "${file.name}", Size: ${file.size}, MIME: ${file.type})`);

    self.reader.readAsArrayBuffer(file);
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
            id: self.currentid,
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
            id: self.currentid,
            data: target.result
        }
    }, [target.result]);

    self.currentid = null;
};

self.currentid = null;
self.reader = new FileReader();

self.reader.addEventListener("load", self.handleReaderEvent);
self.reader.addEventListener("error", self.handleReaderEvent);
self.reader.addEventListener("progress", self.handleReaderEvent);
