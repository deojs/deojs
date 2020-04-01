/**
 * Handles importing of all operations
 */

// Operation imports
import FindReplace from "./FindReplace.mjs";
// import RemoveComments from "./RemoveComments.mjs";
import ReplaceFormatExpression from "./ReplaceFormatExpression.mjs";

class Operations {
    constructor() {
        this.operations = {};

        // Create an object containing all operations so we can refer
        // to them by name (filename)
        this.operations.findreplace = FindReplace;
        // this.operations.removecomments = RemoveComments;
        this.operations.replaceformatexpression = ReplaceFormatExpression;
    }

    /**
     * Finds an operation and returns it
     *
     * @param {string} opName - The operation name
     * @returns {object} - The operation class
     */
    getOperation(opName) {
        const lowerName = opName.toLowerCase();
        if (this.operations[lowerName] !== undefined) {
            return new this.operations[lowerName]();
        }
        throw Error(`Operation "${opName}" does not exist!`);
    }

    /**
     * Gets a list of operations and their options.
     * Returns an object containing the details for all operations
     *
     * @returns {object} - Operations list
     */
    getOperationList() {
        const opNames = Object.keys(this.operations);
        const operations = {};
        for (let i = 0; i < opNames.length; i++) {
            const op = this.getOperation(opNames[i]);
            operations[opNames[i]] = {
                name: opNames[i],
                displayName: op.name,
                args: op.args,
                languages: op.languages,
                inputType: op.inputType,
                outputType: op.outputType,
                progress: op.progress
            };
        }

        return operations;
    }
}

export default Operations;
