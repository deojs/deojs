/**
 * Main worker for the entire App
 *
 * Handles communications between the main thread (UI) and the separate workers
 */

import LanguageHelper from "../helpers/LanguageHelper.mjs";
import InputHelper from "../helpers/InputHelper.mjs";

import InputWorker from "./Input.worker.js";
import OperationWorker from "./Operation.worker.js";

self.createHelpers = function () {
    self.LanguageHelper = new LanguageHelper();
    self.InputHelper = new InputHelper(self);
};

self.createWorkers = function () {
    self.InputWorker = new InputWorker();
    self.InputWorker.addEventListener("message", self.handleInputWorkerMessage.bind(self));
    self.callbacks = {};
    self.callbacksId = 0;
    self.OperationWorker = new OperationWorker();
    self.OperationWorker.addEventListener("message", self.handleOperationWorkerMessage.bind(self));
};

self.handleInputWorkerMessage = function (message) {
    if (!message.data) return;
    const data = message.data;

    if (!data.command) return;
    switch (data.command) {
    case "callback":
        self.callbacks[data.data.callbackid](data.data.data);
        break;
    default:
        console.error(`Invalid command "${data.command}"`);
    }
};

self.handleOperationWorkerMessage = async function (message) {
    if (!message.data) return;
    const data = message.data;

    if (!data.command) return;
    switch (data.command) {
    case "prettyPrint":
        self.OperationWorker.postMessage({
            command: "callback",
            data: {
                callbackid: data.data.callbackid,
                data: self.prettyPrint(data.data.ast, data.data.language)
            }
        });
        break;
    case "parse":
        self.OperationWorker.postMessage({
            command: "callback",
            data: {
                callbackid: data.data.callbackid,
                data: await self.parse(data.data.input, data.data.language)
            }
        });
        break;
    case "complete":
        console.log("Running operations completed.");
        self.postMessage({
            command: "runcomplete",
            data: data.data
        });
        break;
    default:
        console.error(`Invalid command "${data.command}"`);
    }
};

self.addCallback = function (callback) {
    const id = self.callbacksIs;
    self.callbacksId += 1;
    self.callbacks[id] = callback;
    return id;
};

self.loadFile = function (file) {
    const fileObj = self.InputHelper.loadFile(file, self.inputFileLoaded.bind(self));
    self.InputWorker.postMessage({
        command: "newInputFile",
        data: fileObj
    });
};

self.inputFileLoaded = function (data, error) {
    self.InputWorker.postMessage({
        command: "inputFileLoaded",
        data: {
            data: data,
            error: error
        }
    });
    self.postMessage({
        command: "inputFileLoaded",
        data: {
            data: data,
            error: error
        }
    });
};

/**
 * Handle messages sent by the main thread
 *
 * @param e - The message sent by the main thread
 */
self.addEventListener("message", async (e) => {
    if (!e.data) return;
    const data = e.data;

    if (!data.command) return;

    switch (data.command) {
    case "run":
        // Runs the deobfuscation
        self.OperationWorker.postMessage({
            command: "run",
            data: {
                operations: data.data.operations,
                operationClasses: data.data.operationClasses,
                input: await self.parseInput(data.data.language, data.data.encoding),
                language: data.data.language
            }
        });
        break;
    case "loadfile":
        // Loads a new file using the InputWorker
        self.loadFile(data.data);
        break;
    case "getDecodedInput":
        self.postMessage({
            command: "callback",
            data: {
                callbackid: data.data.callbackid,
                data: await self.InputHelper.getDecodedData(data.data.encoding)
            }
        });
        break;
    case "getLanguage":
        self.postMessage({
            command: "callback",
            data: {
                callbackid: data.data.callbackid,
                data: self.LanguageHelper.getLanguage(data.data.language)
            }
        });
        break;
    case "parseInput":
        self.postMessage({
            command: "callback",
            data: {
                callbackid: data.data.callbackid,
                data: await self.parseInput(data.data.language, data.data.encoding)
            }
        });
        break;
    case "prettyPrint":
        self.postMessage({
            command: "callback",
            data: {
                callbackid: data.data.callbackid,
                data: self.prettyPrint(data.data.ast, data.data.language)
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
                data: await self.calculateInputHashes()
            }
        });
        break;
    default:
        console.warn(`Invalid command "${data.command}"`);
    }
});

/**
 * Parses the input
 *
 * @param {string} language - The name of the language to parse
 * @param {string} encoding - The encoding to use when decoding the input
 * @returns {object} - The parsed input
 */
self.parseInput = async function (language, encoding) {
    try {
        const input = await self.InputHelper.getDecodedData(encoding);
        return self.parse(input, language, self.updateInputParseProgress.bind(self));
    } catch (error) {
        console.error(error);
        return [];
    }
};

/**
 * Sends a message to the main thread indicating input parse progress
 *
 * @param {number} current - The current progress
 * @param {number} total - The total progress
 */
self.updateInputParseProgress = function (current, total) {
    self.postMessage({
        command: "inputParseProgress",
        data: {
            current: current,
            total: total
        }
    });
};

/**
 * Parses the input with the specified language and encoding
 *
 * @param {string} input - The text to parse
 * @param {string} language - The language to parse the input with
 * @param {function} progress - A callback which is called to update the progress
 * @returns {object} - Parsed language
 */
self.parse = async function (input, language, progress) {
    try {
        const languageObject = self.LanguageHelper.getLanguage(language);
        return languageObject.parse(input, progress);
    } catch (error) {
        console.error(error);
        return [];
    }
};

/**
 * Pretty prints the input with the specified language
 *
 * @param {object} ast - The AST to pretty print
 * @param {string} language - The language to pretty print
 * @returns {string} - Pretty printed language
 */
self.prettyPrint = function (ast, language) {
    try {
        const languageObject = self.LanguageHelper.getLanguage(language);
        return languageObject.prettyPrint(ast);
    } catch (error) {
        console.error(error);
        return "";
    }
};

/**
 * Scans the input using the InputHelper
 *
 * @returns {JSON} - Scan results
 */
self.scanInput = async function () {
    return new Promise((resolve, reject) => {
        const callbackid = self.addCallback(resolve);
        self.InputWorker.postMessage({
            command: "scanInput",
            data: {
                callbackid: callbackid
            }
        });
    });
};

/**
 * Calculates hashes of the input file
 *
 * @returns {object} - Calculated hashes
 */
self.calculateInputHashes = async function () {
    return new this.Promise((resolve, reject) => {
        const callbackid = self.addCallback(resolve);
        self.InputWorker.postMessage({
            command: "calculateInputHashes",
            data: {
                callbackid: callbackid
            }
        });
    });
};

self.createHelpers();
self.createWorkers();
