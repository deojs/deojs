/**
 * Worker to handle storage and processing of the input file
 */
import CryptoJS from "crypto-js";

// Object containing the input file and data
self.input = null;

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

        const apikey = "1b7fc85d02663a49c39f5961a860406e44eb49f1e633746cbe545c0502194b50";

        const response = await fetch(`${proxyUrl}https://www.virustotal.com/vtapi/v2/file/report?apikey=${apikey}&resource=${hash}`, {
            method: "GET"
        });

        return response.json();
    } catch (error) {
        console.error(error);
        return {};
    }
};

/**
 * Calculates hashes for the input file
 *
 * @returns {object} - Object containing MD5, SHA1 and SHA256 hashes
 */
self.calculateHashes = function () {
    const data = self.getRawData();
    const arrayData = CryptoJS.lib.WordArray.create(data);

    const md5 = CryptoJS.MD5(arrayData);
    const sha1 = CryptoJS.SHA1(arrayData);
    const sha256 = CryptoJS.SHA256(arrayData);

    return {
        md5: md5.toString(),
        sha1: sha1.toString(),
        sha256: sha256.toString()
    };
};
