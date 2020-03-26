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
     * @returns {object} - Parsed code
     */
    parse(inCode) {
        // const lexer = moo.states(this.getTokens());
        // const parser = new nearley.Parser(nearley.Grammar.fromCompiled(grammar));
        // lexer.reset(inCode);

        // let token = lexer.next();
        // while (token !== undefined) {
        //     console.log(token);
        //     token = lexer.next();
        // }

        // return inCode;
        const parser = new nearley.Parser(nearley.Grammar.fromCompiled(grammar));
        const chunkSize = 100; // Characters
        const numChunks = Math.ceil(inCode.length / chunkSize);

        for (let i = 0; i < numChunks; i++) {
            console.log(`Parsing ${(i / numChunks) * 100}%`);
            parser.feed(inCode.slice(i * 100, (i * 100) + 100));
        }
        console.log("Parsing complete");

        if (parser.results.length > 0) {
            return parser.results[0];
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

    // parse function
    // parse function should handle lexing and actual parsing
    // lexing ideally should be a separate function so we can call it separately

    // pretty-print function, nearley should be able to handle this itself
}

export default PowerShellLanguage;
