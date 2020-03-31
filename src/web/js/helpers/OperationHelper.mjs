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
        return new Operation();
    }

    /**
     * Get a list of operations
     *
     * @returns {Array} - Operation list
     */
    getOperationList() {
        return this.opList;
    }

    /**
     * Populates the UI operations list with a list of operations
     */
    populateOperationsList() {
        const operationsList = document.getElementById("operationsList");
        for (let i = 0; i < this.opList.length; i++) {
            operationsList.append(this.createOperationListHtml(this.opList[i]));
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

    }
}

export default OperationHelper;
