/**
 * Find and replace operations for code
 */
class FindReplace {
    constructor() {
        this.name = "Find / Replace";
        this.args = [
            {
                name: "Find (Regex)",
                type: "string",
                default: ""
            },
            {
                name: "Replace text",
                type: "string",
                default: ""
            },
            {
                name: "Global",
                type: "boolean",
                default: true
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
        let flags = "";
        if (args[2]) flags += "g";
        const re = new RegExp(args[0], flags);
        return input.replace(re, args[1]);
    }
}

export default FindReplace;
