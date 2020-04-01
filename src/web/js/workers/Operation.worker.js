/**
 * Worker to handle running operations
 */
import OperationHelper from "../helpers/OperationHelper.mjs";

self.callbacks = {};
self.callbacksId = 0;

self.OperationHelper = new OperationHelper(self);

self.addCallback = function (callback) {
    const callbackid = self.callbacksId;
    self.callbacksId += 1;
    self.callbacks[callbackid] = callback;
    return callbackid;
};

self.run = async function (input, language, operations) {
    let currentInput = input;
    for (let i = 0; i < operations.length; i++) {
        console.log(`Running operation ${i} (${operations[i].displayName})`);

        const opClass = self.OperationHelper.getOperation(operations[i].name);
        let opInput = currentInput;

        // If needed, convert current data to string
        if (operations[i].inputType === "string") {
            opInput = await new Promise((resolve, reject) => {
                self.postMessage({
                    command: "prettyPrint",
                    data: {
                        callbackid: self.addCallback(resolve),
                        ast: opInput,
                        language: language
                    }
                });
            });
        }

        // Run the operation
        let opOutput = opClass.run(opInput, operations[i].args);

        // If needed, convert output data to AST
        if (operations[i].outputType === "string") {
            opOutput = await new Promise((resolve, reject) => {
                self.postMessage({
                    command: "parse",
                    data: {
                        callbackid: self.addCallback(resolve),
                        input: opOutput,
                        language: language
                    }
                });
            });
        }

        currentInput = opOutput;
    }

    self.postMessage({
        command: "complete",
        data: {
            language: language,
            output: await new this.Promise((resolve, reject) => {
                self.postMessage({
                    command: "prettyPrint",
                    data: {
                        callbackid: self.addCallback(resolve),
                        ast: currentInput,
                        language: language
                    }
                });
            })
        }
    });
};

self.addEventListener("message", (e) => {
    if (!e.data) return;
    const data = e.data;

    if (!data.command) return;

    switch (data.command) {
    case "run":
        self.run(data.data.input, data.data.language, data.data.operations, data.data.operationClasses);
        break;
    case "callback":
        self.callbacks[data.data.callbackid](data.data.data);
        break;
    default:
        console.error(`Invalid command "${data.command}"`);
    }
});
