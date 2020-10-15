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
        return this.operations.getOperationDetails(opName);
    }

    /**
     * Get a list of operations.
     * Returns an object containing the details for all operations
     *
     * @returns {object} - Operation list
     */
    getOperationList() {
        return this.operations.getOperationList();
    }

    /**
     * Get a list of debug operations.
     * Returns an object containing the details for all debug operations
     *
     * @returns {object} - Debug operation list
     */
    getDebugOperationList() {
        return this.operations.getDebugOperationList();
    }

    /**
     * Populates the UI operations list with a list of operations
     *
     * @param {boolean} debug - Set to true to include debug operations
     */
    populateOperationsList(debug = false) {
        const operationsList = document.getElementById("operationsList");
        let opList = this.getOperationList();
        let opNames = Object.keys(opList);
        for (let i = 0; i < opNames.length; i++) {
            operationsList.append(this.createOperationListHtml(opList[opNames[i]]));
        }

        if (debug) {
            opList = this.getDebugOperationList();
            opNames = Object.keys(opList);
            for (let i = 0; i < opNames.length; i++) {
                operationsList.append(this.createOperationListHtml(opList[opNames[i]]));
            }
        }
    }

    /**
     * Clears the UI operations list
     */
    clearOperationsList() {
        const operationsList = document.getElementById("operationsList");
        for (let i = operationsList.children.length - 1; i >= 0; i--) {
            operationsList.children.item(i).remove();
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
        const titleElement = document.createElement("span");
        titleElement.innerText = operation.displayName;
        operationElement.appendChild(titleElement);

        operationElement.setAttribute("opName", operation.name);
        operationElement.setAttribute("data-toggle", "tooltip");
        operationElement.setAttribute("data-placement", "right");
        operationElement.setAttribute("title", operation.description);
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
        // Disable run button
        const runButton = document.getElementById("runFlowButton");
        runButton.innerText = "Running...";
        runButton.setAttribute("disabled", "true");

        // Change output status icon to a rotating dash
        const outputIcon = document.getElementById("outputStatusIcon");
        this.App.UIHelper.updateStatusIcon(outputIcon, "loading");

        // Create a list of operations to run
        const operationList = document.getElementById("flowList");
        const operationElements = operationList.children;

        const operationsUsed = {};
        const opsList = [];
        for (let i = 0; i < operationElements.length; i++) {
            const opElement = operationElements.item(i);
            operationsUsed[opElement.getAttribute("opName")] = true;

            // Update the status indicator for the operation
            this.updateOpStatus(i, opElement.getAttribute("opName"), "waiting", "Operation is waiting to be executed");

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

        const outputData = await this.App.OutputHelper.getOutput(-1, true);
        document.getElementById("outputArea").innerHTML = outputData.output;

        // Enable run button
        const runButton = document.getElementById("runFlowButton");
        runButton.innerText = "Run";
        runButton.removeAttribute("disabled");

        // Set output status icon
        const outputIcon = document.getElementById("outputStatusIcon");
        if (outputData.parses) {
            this.App.UIHelper.updateStatusIcon(outputIcon, "success", "All operations have completed execution and the result parses");
        } else {
            this.App.UIHelper.updateStatusIcon(outputIcon, "warning", "All operations have completed execution, but the result does not parse");
        }
    }

    /**
     * Updates the status indicator for an operation
     *
     * @param {number} opIndex - The index of the operation in the flow list
     * @param {string} opName - The name of the operation
     * @param {string} status - The status to update the icon to
     * @param {string} tooltipText - The text to set the icon tooltip text to
     */
    updateOpStatus(opIndex, opName, status, tooltipText) {
        const opList = document.getElementById("flowList");
        const ops = opList.children;
        if (ops.length <= opIndex) return;

        if (ops[opIndex].getAttribute("opName") === opName) {
            const icon = ops[opIndex].getElementsByClassName("statusIcon")[0];
            this.App.UIHelper.updateStatusIcon(icon, status, tooltipText);
        }
    }
}

export default OperationHelper;
