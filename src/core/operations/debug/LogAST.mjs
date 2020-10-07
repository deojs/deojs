/**
 * Logs the parsed AST to the console
 */
class LogAST {
    constructor() {
        this.name = "(DEBUG) Log AST to console";
        this.args = [];
        this.languages = []; // Empty array = all languages
        this.inputType = "ast"; // Input is a string (not an AST object)
        this.outputType = "ast"; // Output is a string (not an AST object)
        this.progress = false; // Don't pass this operation a progress function
    }

    /**
     * Run function
     *
     * @param {Object} input - The input code
     * @param {Array} args - The operation arguments
     * @returns {Object} - The unmodified code
     */
    run(input, args) {
        console.log(input);
        return input;
    }
}

export default LogAST;
