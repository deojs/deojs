/**
 * Worker to handle storage and processing of the input file
 */
import CryptoJS from "crypto-js";
import HashWorker from "./Hash.worker.js";

// Object containing the input file and data
self.input = null;

// Object containing hash worker callbacks
self.hashCallbacks = {};
self.hashCallbackId = 0;

/**
 * Handle messages sent by the main thread
 */
self.addEventListener("message", async (e) => {
    if (!e.data) return;
    const data = e.data;

    if (!data.command) return;
    switch (data.command) {
    case "newInputFile":
        self.input = data.data;
        break;
    case "inputFileLoaded":
        self.inputFileLoaded(data.data.data);
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
    case "getRawData":
        self.postMessage({
            command: "callback",
            data: {
                callbackid: data.data.callbackid,
                data: self.getRawData()
            }
        });
        break;
    case "scanInput":
        self.postMessage({
            command: "callback",
            data: {
                callbackid: data.data.callbackid,
                data: await self.scanInput()
            }
        });
        break;
    case "calculateInputHashes":
        self.postMessage({
            command: "callback",
            data: {
                callbackid: data.data.callbackid,
                data: await self.calculateHashes()
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

/**
 * Returns the raw ArrayBuffer
 *
 * @returns {ArrayBuffer} - The input data
 */
self.getRawData = function () {
    if (!self.input || !self.input.data) {
        return new ArrayBuffer();
    }
    return self.input.data;
};

/**
 * Scans the input for known malware
 *
 * @returns {JSON} - Response
 */
self.scanInput = async function () {
    try {
        const proxyUrl = "http://localhost:8000/";
        const rawData = self.getRawData();
        const arrayData = CryptoJS.lib.WordArray.create(rawData);
        const hash = CryptoJS.SHA256(arrayData).toString();

        const apikey = "";

        const response = await fetch(`${proxyUrl}https://www.virustotal.com/vtapi/v2/file/report?apikey=${apikey}&resource=${hash}`, {
            method: "GET"
        });

        return response.json();
    } catch (error) {
        console.error(error);
        return {};
    }
};

self.handleHashWorkerMessage = function (message) {
    if (!message.data) return;
    const data = message.data;

    if (!data.command) return;
    switch (data.command) {
    case "callback":
        self.hashCallbacks[data.data.callbackid](data.data.data);
        break;
    default:
        console.error(`Unknown command "${data.command}"`);
    }
};

self.addHashWorkerCallback = function (callback) {
    const id = self.hashCallbackId++;
    self.hashCallbacks[id] = callback;
    return id;
};

/**
 * Calculates hashes for the input file
 *
 * @returns {object} - Object containing MD5, SHA1 and SHA256 hashes
 */
self.calculateHashes = async function () {
    const data = self.getRawData();

    const md5Worker = new HashWorker();
    const sha1Worker = new HashWorker();
    const sha256Worker = new HashWorker();
    md5Worker.addEventListener("message", self.handleHashWorkerMessage.bind(self));
    sha1Worker.addEventListener("message", self.handleHashWorkerMessage.bind(self));
    sha256Worker.addEventListener("message", self.handleHashWorkerMessage.bind(self));

    const md5 = new Promise((resolve, reject) => {
        md5Worker.postMessage({
            command: "hashArrayBuffer",
            data: {
                callbackId: self.addHashWorkerCallback(resolve),
                data: data,
                algorithm: "md5"
            }
        });
    });
    const sha1 = new Promise((resolve, reject) => {
        sha1Worker.postMessage({
            command: "hashArrayBuffer",
            data: {
                callbackId: self.addHashWorkerCallback(resolve),
                data: data,
                algorithm: "sha1"
            }
        });
    });
    const sha256 = new Promise((resolve, reject) => {
        sha256Worker.postMessage({
            command: "hashArrayBuffer",
            data: {
                callbackId: self.addHashWorkerCallback(resolve),
                data: data,
                algorithm: "sha256"
            }
        });
    });

    let md5String;
    let sha1String;
    let sha256String;

    await Promise.all([md5, sha1, sha256]).then((values) => {
        console.log(values);
        md5String = values[0];
        sha1String = values[1];
        sha256String = values[2];
    });

    return {
        md5: md5String,
        sha1: sha1String,
        sha256: sha256String
    };
};
