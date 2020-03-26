/**
 * Main worker for the entire App
 *
 * Handles communications between the main thread (UI) and the separate workers
 */

import LanguageHelper from "../helpers/LanguageHelper.mjs";
import InputHelper from "../helpers/InputHelper.mjs";

import InputWorker from "./Input.worker.js";

self.createHelpers = function () {
    self.LanguageHelper = new LanguageHelper();
    self.InputHelper = new InputHelper(self);
};

self.createWorkers = function () {
    self.InputWorker = new InputWorker();
    self.InputWorker.addEventListener("message", self.handleInputWorkerMessage.bind(self));
    self.InputWorkerCallbacks = {};
    self.InputWorkerCallbackId = 0;
};

self.handleInputWorkerMessage = function (message) {
    if (!message.data) return;
    const data = message.data;

    if (!data.command) return;
    switch (data.command) {
    case "callback":
        self.InputWorkerCallbacks[data.data.callbackid](data.data.data);
        break;
    default:
        console.error(`Invalid command "${data.command}"`);
    }
};

self.addInputWorkerCallback = function (callback) {
    const id = self.InputWorkerCallbackId;
    self.InputWorkerCallbackId += 1;
    self.InputWorkerCallbacks[id] = callback;
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
        console.log("run");
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
        return self.parse(input, language);
    } catch (error) {
        console.error(error);
        return [];
    }
};

/**
 * Parses the input with the specified language and encoding
 *
 * @param {string} input - The text to parse
 * @param {string} language - The language to parse the input with
 * @returns {object} - Parsed language
 */
self.parse = async function (input, language) {
    try {
        const languageObject = self.LanguageHelper.getLanguage(language);
        return languageObject.parse(input);
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

self.createHelpers();
self.createWorkers();
