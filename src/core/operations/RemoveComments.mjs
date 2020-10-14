/**
 * Remove comments from code
 */
class RemoveComments {
    constructor() {
        this.name = "Remove Comments";
        this.description = "Removes single line and delimited comments from the code.";
        this.args = [];
        this.languages = ["powershell"];
        this.inputType = "ast";
        this.outputType = "ast";
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
                return;
            }
            if (typeof obj === "string") {
                return;
            }
            if (Array.isArray(obj)) {
                for (let i = 0; i < obj.length; i++) {
                    recurse(obj[i]);
                }
            }
            if (Object.prototype.hasOwnProperty.call(obj, "data")
            && Object.prototype.hasOwnProperty.call(obj, "type")) {
                if (obj.type === "singleLineComment" || obj.type === "delimitedComment") {
                    obj.data = null;
                    return;
                }
                recurse(obj.data);
            }
        };
        recurse(input);
        return input;
    }
}

export default RemoveComments;
