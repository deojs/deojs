import CustomError from "../../utils/CustomError.mjs";

/**
 * Debug operation which throws an error
 */
class ThrowError {
    constructor() {
        this.name = "(DEBUG) Throw error";
        this.args = [
            {
                name: "Error type",
                type: "dropdown",
                default: "Error",
                options: [
                    "Error",
                    "CustomError"
                ]
            }
        ];
        this.languages = [];
        this.inputType = "ast";
        this.outputType = "ast";
        this.progress = false;
    }

    /**
     * Run function
     *
     * @param {object} input - The input code
     * @param {Array} args - The operation arguments
     */
    run(input, args) {
        if (args[0] === "Error") {
            throw new Error("Test error");
        } else {
            throw new CustomError("Test Error");
        }
    }
}

export default ThrowError;