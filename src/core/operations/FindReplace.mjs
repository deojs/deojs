/**
 * Find and replace operations for code
 */
class FindReplace {
    constructor() {
        this.name = "Find / Replace";
        this.args = [
            {
                name: "Find text",
                type: "string"
            },
            {
                name: "Replace text",
                type: "string"
            }
        ];
        this.languages = []; // Empty array = all languages
        this.inputType = "string"; // Input is a string (not an AST object)
        this.outputType = "string"; // Output is a string (not an AST object)
        this.progress = false; // Don't pass this operation a progress function
    }

    /**
     * Run function
     *
     * @param {string} input - The input code
     * @param {Array} args - The operation arguments
     * @returns {string} - The modified code
     */
    run(input, args) {
        return input.replace(args[0], args[1]);
    }
}

export default FindReplace;
