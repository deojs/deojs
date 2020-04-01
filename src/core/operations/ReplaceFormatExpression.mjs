/**
 * Replaces Format Expressions with the actual text
 */
class ReplaceFormatExpression {
    constructor() {
        this.name = "Replace Format Expressions";
        this.args = [];
        this.languages = ["powershell"];
        this.inputType = "ast";
        this.outputType = "string";
        this.progress = false;
    }

    /**
     * Creates an array of the format expression strings
     *
     * @param {object} formatExpressionData - The section of the AST to traverse
     * @returns {Array} - The expression strings
     */
    getFormatExpressionStrings(formatExpressionData) {
        const recurse = function (obj) {
            if (obj === null || obj === undefined) {
                return null;
            }
            if (typeof obj === "string") {
                return null;
            }
            if (Array.isArray(obj)) {
                const out = [];
                for (let i = 0; i < obj.length; i++) {
                    const data = recurse(obj[i]);
                    if (data !== null) {
                        if (Array.isArray(data)) {
                            out.concat(data);
                        } else {
                            out.push(data);
                        }
                    }
                }
                if (out.length === 0) {
                    return null;
                }
                if (out.length === 1) {
                    return out[0];
                }
                return out;
            }
            if (Object.prototype.hasOwnProperty.call(obj, "type") &&
                Object.prototype.hasOwnProperty.call(obj, "data")) {
                if (obj.type === "verbatimStringLiteral") {
                    return this.prettyPrint(obj.data[1]);
                }
            }
            if (Object.prototype.hasOwnProperty.call(obj, "data")) {
                return recurse(obj.data);
            }

            return null;
        }.bind(this);

        console.log(recurse(formatExpressionData));

        return [];
    }

    /**
     * Replaces a format expression with the actual string
     *
     * @param {object} formatExpression - The format expression in the syntax tree
     * @returns {string} - The replaced format expression
     */
    replaceFormatExpression(formatExpression) {
        // console.log(formatExpression);
        let outStr = this.prettyPrint(formatExpression[0]);
        this.getFormatExpressionStrings(formatExpression[2]);

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
     * @param {object} input - The input AST
     * @param {Array} args - The operation arguments
     * @returns {object} - The modified AST
     */
    run(input, args) {
        const recurse = function (obj) {
            if (obj === null || obj === undefined) {
                return null;
            }
            if (typeof obj === "string") {
                return obj;
            }
            if (Array.isArray(obj)) {
                const out = [];
                for (let i = 0; i < obj.length; i++) {
                    out.push(recurse(obj[i]));
                }
                return out;
            }
            if (Object.prototype.hasOwnProperty.call(obj, "type") &&
                Object.prototype.hasOwnProperty.call(obj, "data")) {
                if (obj.type === "formatExpression") {
                    return this.replaceFormatExpression(obj.data);
                }
            }
            if (Object.prototype.hasOwnProperty.call(obj, "data")) {
                obj.data = recurse(obj.data);
                return obj;
            }

            return obj;
        }.bind(this);

        const out = recurse(input);

        return this.prettyPrint(input);
    }
}

export default ReplaceFormatExpression;
