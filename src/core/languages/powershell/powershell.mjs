import nearley from "nearley";

import grammar from "./parsing/grammar.js";

/**
 * Class for handling PowerShell code.
 * This includes, lexing, parsing, and pretty-printing
 */
class PowerShellLanguage {
    /**
     * Lexes and parses inCode
     *
     * @param {string} inCode The code to be parsed
     * @param {Function} progress A callback to call to update progress
     * @returns {object} - Parsed code
     */
    parse(inCode, progress) {
        const parser = new nearley.Parser(nearley.Grammar.fromCompiled(grammar));
        const chunkSize = 100; // Characters
        const numChunks = Math.ceil(inCode.length / chunkSize);
        for (let i = 0; i < numChunks; i++) {
            if (progress !== undefined
                && progress !== null
                && typeof progress === "function") {
                progress(i, numChunks);
            }
            parser.feed(inCode.slice(i * 100, (i * 100) + 100));
        }
        if (Object.prototype.hasOwnProperty.call(parser, "results")) {
            console.log(`Parse produced ${parser.results.length} results.`);
            if (parser.results.length > 0) {
                return parser.results[0];
            }
        }

        return {};
    }

    /**
     * Pretty prints a powershell AST
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
}

export default PowerShellLanguage;
