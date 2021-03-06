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
    let currentInput = input.ast;
    let error = false;
    const outputs = [];

    outputs.push({
        opName: "",
        opArgs: [],
        opOutputAST: input.ast,
        opOutputString: input.string,
        language: language
    });

    for (let i = 0; i < operations.length; i++) {
        console.log(`Running operation ${i} (${operations[i].displayName})`);
        // Update status of operation
        self.postMessage({
            command: "updateOpStatus",
            data: {
                opIndex: i,
                opName: operations[i].name,
                status: "loading",
                tooltipText: "Operation is executing"
            }
        });

        const opClass = self.OperationHelper.getOperation(operations[i].name);
        let opInput = currentInput;

        // If needed, convert current data to string
        if (operations[i].inputType === "string" && typeof currentInput !== "string") {
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
        let opOutput;
        try {
            opOutput = opClass.run(opInput, operations[i].args);
        } catch (e) {
            console.error(e);
            error = true;
            self.postMessage({
                command: "updateOpStatus",
                data: {
                    opIndex: i,
                    opName: operations[i].name,
                    status: "error",
                    tooltipText: e.toString()
                }
            });
            break;
        }

        let opOutputAST = opOutput;
        let opOutputString = opOutput;

        // If needed, convert output data to AST
        if (operations[i].outputType === "string") {
            opOutputAST = await new Promise((resolve, reject) => {
                self.postMessage({
                    command: "parse",
                    data: {
                        callbackid: self.addCallback(resolve),
                        input: opOutput,
                        language: language
                    }
                });
            });
        } else {
            opOutputString = await new Promise((resolve, reject) => {
                self.postMessage({
                    command: "prettyPrint",
                    data: {
                        callbackid: self.addCallback(resolve),
                        ast: opOutput,
                        language: language
                    }
                });
            });
        }

        outputs.push({
            opName: operations[i].name,
            opArgs: operations[i].args,
            opOutputAST: opOutputAST,
            opOutputString: opOutputString,
            language: language
        });

        if (i + 1 < operations.length
            && operations[i].outputType === operations[i + 1].inputType) {
            currentInput = opOutput;
        } else {
            currentInput = opOutputAST;
        }

        let status = "success";
        let tooltipText = "Operation execution has completed and the result parses successfully.";
        // Update status of operation
        if (!Object.prototype.hasOwnProperty.call(opOutputAST, "data")) {
            status = "warning";
            tooltipText = "Operation execution has completed, but the result does not parse";
        }
        self.postMessage({
            command: "updateOpStatus",
            data: {
                opIndex: i,
                opName: operations[i].name,
                status: status,
                tooltipText: tooltipText
            }
        });
    }

    self.postMessage({
        command: "complete",
        data: {
            language: language,
            outputs: outputs,
            error: error
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
