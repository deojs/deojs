/**
 * Helper for loading and running operations
 */

import Operations from "../../../core/operations/operations.mjs";

class OperationHelper {
    constructor(App) {
        this.App = App;
        this.callbacks = {};
        this.currentId = 0;
        this.operations = new Operations();
        this.opList = this.operations.getOperationList();
    }

    /**
     * Gets a new instance of the class for the specified operation
     *
     * @param {string} opName - The name of the operation
     * @returns {object} - Operation class
     */
    getOperation(opName) {
        const Operation = this.operations.getOperation(opName);
        return Operation;
    }

    /**
     * Gets the details for an operation
     *
     * @param {string} opName - The name of the operation
     * @returns {object} - Operation details
     */
    getOperationDetails(opName) {
        return this.opList[opName];
    }

    /**
     * Get a list of operations.
     * Returns an object containing the details for all operations
     *
     * @returns {object} - Operation list
     */
    getOperationList() {
        return this.opList;
    }

    /**
     * Populates the UI operations list with a list of operations
     */
    populateOperationsList() {
        const operationsList = document.getElementById("operationsList");
        const opNames = Object.keys(this.opList);
        for (let i = 0; i < opNames.length; i++) {
            operationsList.append(this.createOperationListHtml(this.opList[opNames[i]]));
        }
    }

    /**
     * Creates the HTML for an operation to be displayed in the selection list
     *
     * @param {object} operation - The operation details
     * @returns {HTMLElement} - The created operation HTML
     */
    createOperationListHtml(operation) {
        const operationElement = document.createElement("li");
        operationElement.innerText = operation.displayName;
        operationElement.setAttribute("opName", operation.name);
        return operationElement;
    }

    /**
     * Creates the HTML for an operation to be displayed in the main pane
     *
     * @param {object} operation - The operation details
     * @returns {HTMLElement} - The created operation HTML
     */
    createOperationHtml(operation) {
        const argContainer = document.createElement("div");
        argContainer.id = "argContainer";

        for (let i = 0; i < operation.args.length; i++) {
            const arg = operation.args[i];
            const label = document.createElement("label");
            label.innerText = arg.name;
            label.classList.add("opArgLabel");
            argContainer.appendChild(label);

            switch (arg.type) {
            case "string": {
                const strInput = document.createElement("input");
                strInput.setAttribute("type", "text");
                strInput.classList.add("operationArgument");
                strInput.value = arg.default;
                argContainer.appendChild(strInput);
                break;
            }
            case "boolean": {
                const checkInput = document.createElement("input");
                checkInput.setAttribute("type", "checkbox");
                checkInput.classList.add("operationArgument");
                checkInput.checked = arg.default;
                argContainer.appendChild(checkInput);
                break;
            }
            case "dropdown": {
                const dropInput = document.createElement("select");
                dropInput.classList.add("operationArgument");
                dropInput.setAttribute("type", "dropdown");

                for (let x = 0; x < arg.options.length; x++) {
                    const opElement = document.createElement("option");
                    opElement.setAttribute("value", arg.options[x]);
                    opElement.innerText = arg.options[x];

                    if (arg.options[x] === arg.default) {
                        opElement.setAttribute("selected", "selected");
                    }

                    dropInput.appendChild(opElement);
                }

                argContainer.appendChild(dropInput);
                break;
            }
            default:
                console.error(`Unknown argument type "${arg.type}".`);
            }
            argContainer.appendChild(document.createElement("br"));
        }

        return argContainer;
    }

    /**
     * Runs the operations by sending them to the operationWorker
     */
    async run() {
        // Create a list of operations to run
        const operationList = document.getElementById("flowList");
        const operationElements = operationList.children;

        const operationsUsed = {};
        const opsList = [];
        for (let i = 0; i < operationElements.length; i++) {
            const opElement = operationElements.item(i);
            operationsUsed[opElement.getAttribute("opName")] = true;

            const args = [];
            const argElements = opElement.getElementsByClassName("operationArgument");
            for (let x = 0; x < argElements.length; x++) {
                const argElement = argElements.item(x);
                switch (argElement.getAttribute("type")) {
                case "text":
                    args.push(argElement.value);
                    break;
                case "checkbox":
                    args.push(argElement.checked);
                    break;
                case "dropdown":
                    args.push(argElement.value);
                    break;
                default:
                    console.error(`Unknown input element type ${argElement.getAttribute("type")}`);
                }
            }

            const opDetails = this.getOperationDetails(opElement.getAttribute("opName"));
            opDetails.args = args;
            opsList.push(opDetails);
        }

        const operationClasses = {};
        const opNames = Object.keys(operationsUsed);
        for (let i = 0; i < opNames.length; i++) {
            // Create a new instance of the operation and add it to the object
            operationClasses[opNames[i]] = this.getOperation(opNames[i]);
        }

        this.App.AppWorker.postMessage({
            command: "run",
            data: {
                language: "powershell",
                encoding: "utf-8",
                operations: opsList
            }
        });
    }

    /**
     * Executed when the OperationWorker completes execution
     *
     * @param {object} output - The output data
     * @param {string} language - The output language
     */
    async runComplete(output, language) {
        this.App.OutputHelper.updateOutput(output, language);

        const outputData = await this.App.OutputHelper.getOutput(true);
        document.getElementById("outputArea").innerHTML = outputData;
    }
}

export default OperationHelper;
