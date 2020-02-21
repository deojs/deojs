/**
 * Worker to handle storage and processing of the input file
 */

// Object containing the input file and data
self.input = null;

/**
 * Handle messages sent by the main thread
 */
self.addEventListener("message", (e) => {
    if (!e.data) return;
    const data = e.data;

    if (!data.command) return;
    switch (data.command) {
    case "newInputFile":
        self.input = data.data;
        break;
    case "inputFileLoaded":
        self.inputFileLoaded(data.data);
        break;
    case "getDecodedData":
        self.postMessage({
            command: "callback",
            data: {
                callbackid: data.data.callbackid,
                data: self.getDecodedData(data.data.encoding)
            }
        });
        break;
    default:
        console.error(`Invalid command "${data.command}"`);
    }
});

/**
 * Handles the input file finishing loading
 *
 * @param {object} data - The file data sent from the main thread
 */
self.inputFileLoaded = function (data) {
    if (!data.file || !data.data) {
        console.error("Invalid file object");
        return;
    }
    if (data.file.id !== self.input.id) {
        console.error(`Invalid input file ID. Stored: ${self.input.id}, Sent: ${data.id}`);
        return;
    }

    self.input.data = data.data;
};

/**
 * Decodes the stored data to a string and returns it
 *
 * @param {string} encoding - The format to decode the string
 * @returns {string} - The decoded string
 */
self.getDecodedData = function (encoding) {
    if (!self.input || !self.input.data) {
        return "";
    }
    const decoder = new TextDecoder(encoding);
    const decoded = decoder.decode(new Uint8Array(self.input.data));
    return decoded;
};
