/**
 * Handles importing of all operations
 */

// Operation imports
import FindReplace from "./FindReplace.mjs";
import RemoveComments from "./RemoveComments.mjs";
import ReplaceAliases from "./ReplaceAliases.mjs";
import ReplaceFormatExpression from "./ReplaceFormatExpression.mjs";
import ConcatenateStrings from "./ConcatenateStrings.mjs";

// Debug operation imports
import LogAST from "./debug/LogAST.mjs";
import ThrowError from "./debug/ThrowError.mjs";

class Operations {
    constructor() {
        this.operations = {};
        this.debugoperations = {};

        // Create an object containing all operations so we can refer
        // to them by name (filename)
        this.operations.concatenatestrings = ConcatenateStrings;
        this.operations.findreplace = FindReplace;
        this.operations.removecomments = RemoveComments;
        this.operations.replacealiases = ReplaceAliases;
        this.operations.replaceformatexpression = ReplaceFormatExpression;

        this.debugoperations.logast = LogAST;
        this.debugoperations.throwerror = ThrowError;
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
        if (this.debugoperations[lowerName] !== undefined) {
            return new this.debugoperations[lowerName]();
        }
        throw Error(`Operation "${opName}" does not exist!`);
    }

    /**
     * Gets the details of an operation
     *
     * @param {string} opName - The operation name
     * @returns {object} - The operation details
     */
    getOperationDetails(opName) {
        const op = this.getOperation(opName);
        return {
            name: opName,
            displayName: op.name,
            args: op.args,
            languages: op.languages,
            inputType: op.inputType,
            outputType: op.outputType,
            description: op.description,
            progress: op.progress
        };
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
            operations[opNames[i]] = this.getOperationDetails(opNames[i]);
        }
        return operations;
    }

    /**
     * Gets a list of debug operations and their options.
     * Returns an object containing the details for all debug operations
     *
     * @returns {object} - Debug operations list
     */
    getDebugOperationList() {
        const opNames = Object.keys(this.debugoperations);
        const operations = {};
        for (let i = 0; i < opNames.length; i++) {
            operations[opNames[i]] = this.getOperationDetails(opNames[i]);
        }
        return operations;
    }
}

export default Operations;
