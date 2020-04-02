/**
 * Remove comments from code
 */
class RemoveComments {
    constructor() {
        this.name = "Remove Comments";
        this.args = [];
        this.languages = ["powershell"];
        this.inputType = "ast";
        this.outputType = "string";
        this.progress = false;
    }

    /**
     * Run function
     *
     * @param {object} input - The input AST
     * @param {Array} args - The operation arguments
     * @returns {string} - The modified AST
     */
    run(input, args) {
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
            if (Object.prototype.hasOwnProperty.call(obj, "data")
            && Object.prototype.hasOwnProperty.call(obj, "type")) {
                if (obj.type === "singleLineComment" || obj.type === "delimitedComment") {
                    return "";
                }
                return recurse(obj.data);
            }

            return "";
        };

        return recurse(input);
    }
}

export default RemoveComments;
