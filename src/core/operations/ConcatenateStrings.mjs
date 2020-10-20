import CustomError from "../utils/CustomError.mjs";

/**
 * Concatenates strings
 */
class ConcatenateStrings {
    constructor() {
        this.name = "Concatenate Strings";
        this.description = "Performs string concatenation on strings which have been split apart.";
        this.args = [];
        this.languages = []; // Empty array = all languages
        this.inputType = "ast"; // Input is a string (not an AST object)
        this.outputType = "ast"; // Output is a string (not an AST object)
        this.progress = false; // Don't pass this operation a progress function
    }

    /**
     *
     * @param {object} ast - The AST segment to search for additive expressions
     * @returns {string} - An array of strings to concatenate
     */
    concatenateExpressionStrings(ast) {
        const recurse = function (obj) {
            if (obj === null || obj === undefined) return null;
            if (typeof obj === "string") return null;

            if (Object.prototype.hasOwnProperty.call(obj, "type")
                && Object.prototype.hasOwnProperty.call(obj, "data")) {
                if (obj.type === "verbatimStringLiteral") {
                    return this.prettyPrint(obj.data[1]);
                }

                if (obj.type === "additiveExpression"
                    && Array.isArray(obj.data)
                    && obj.data.length > 1) {
                    let strings = [];
                    const resultLeft = recurse(obj.data[0]);
                    const resultRight = recurse(obj.data[obj.data.length - 1]);

                    if (Array.isArray(resultLeft)) {
                        strings = strings.concat(resultLeft);
                    } else if (typeof resultLeft === "string") {
                        strings.push(resultLeft);
                    }

                    if (Array.isArray(resultRight)) {
                        strings = strings.concat(resultRight);
                    } else if (typeof resultRight === "string") {
                        strings.push(resultRight);
                    }

                    return strings;
                }

                // Reject expressions which aren't concatenating strings
                if (obj.type === "primaryExpression"
                    && obj.data[0].type !== "value") {
                    throw new CustomError("Not a string concatenation.");
                }
                if (obj.type === "value"
                    && obj.data[0].type !== "stringLiteral") {
                    throw new CustomError("Not a string concatenation.");
                }

                return recurse(obj.data);
            }
            if (Array.isArray(obj)) {
                let out = [];
                for (let i = 0; i < obj.length; i++) {
                    const data = recurse(obj[i]);
                    if (data !== null) {
                        if (Array.isArray(data)) {
                            out = out.concat(data);
                        } else {
                            out.push(data);
                        }
                    }
                }
                if (out.length === 0) return null;
                if (out.length === 1) return out[0];
            }
            return null;
        }.bind(this);

        const output = recurse(ast);
        if (Array.isArray(output)) {
            let out = "";
            for (let i = 0; i < output.length; i++) {
                out += output[i];
            }
            return out;
        }
        return this.prettyPrint(ast);
    }

    /**
     * Searches an additive expression to make sure it only uses strings (or other additive expressions)
     *
     * @param {object} expression - The additive expression to process
     * @returns {object} - The modified expression
     */
    processExpression(expression) {
        try {
            const strings = this.concatenateExpressionStrings(expression);
            return strings;
        } catch (error) {
            if (error instanceof CustomError) {
                // Use error handling to reject expressions which
                // aren't just strings
                return expression;
            }
            console.error(error);
            return expression;
        }
    }

    /**
     * Pretty prints a powershell AST - COPIED FROM POWERSHELL.MJS FOR NOW
     *
     * @param {object} ast - The AST to pretty print
     * @returns {string} - Pretty printed code
     */
    prettyPrint(ast) {
        const recurse = function (obj) {
            if (obj === null || obj === undefined) {
                return "";
            }
            if (typeof obj === "string") {
                return obj;
            }
            if (Array.isArray(obj)) {
                let out = "";
                for (let i = 0; i < obj.length; i++) {
                    out += recurse(obj[i]);
                }
                return out;
            }
            if (Object.prototype.hasOwnProperty.call(obj, "data")) {
                return recurse(obj.data);
            }

            return "";
        };

        return recurse(ast);
    }

    /**
     * Run function
     *
     * @param {object} input - The input code
     * @param {Array} args - The operation arguments
     * @returns {object} - The modified code
     */
    run(input, args) {
        const recurse = function (obj) {
            if (obj === null || obj === undefined) return null;
            if (typeof obj === "string") return obj;

            if (Array.isArray(obj)) {
                const out = [];
                for (let i = 0; i < obj.length; i++) {
                    out.push(recurse(obj[i]));
                }
                return out;
            }
            if (Object.prototype.hasOwnProperty.call(obj, "type")
                && Object.prototype.hasOwnProperty.call(obj, "data")) {
                if (obj.type === "additiveExpression") {
                    obj = this.processExpression(obj);
                    return obj;
                }
                obj.data = recurse(obj.data);
                return obj;
            }

            return null;
        }.bind(this);

        const out = recurse(input);
        return out;
    }
}

export default ConcatenateStrings;
