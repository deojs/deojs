import moo from "moo";

import tokens from "./tokens.mjs";

/**
 * Class for handling PowerShell code.
 * This includes, lexing, parsing, and pretty-printing
 */
class PowerShellLanguage {
    constructor() {
        this.tokens = tokens;
    }

    /**
     * Gets the tokens object for this instance
     *
     * @returns {object} - The tokens for the language
     */
    getTokens() {
        return this.tokens;
    }

    /**
     * Lexes and parses inCode
     *
     * @param {string} inCode The code to be parsed
     * @returns {object} - Parsed code
     */
    parse(inCode) {
        this.lex(inCode);
        return inCode;
    }

    /**
     * Lexes the provided code
     *
     * @param {string} inCode Input code to be parsed
     */
    lex(inCode) {
        const lexer = moo.states(this.getTokens());
        lexer.reset(inCode);

        let token = lexer.next();
        while (token !== undefined) {
            console.log(token);
            token = lexer.next();
        }
    }

    // parse function
    // parse function should handle lexing and actual parsing
    // lexing ideally should be a separate function so we can call it separately

    // pretty-print function, nearley should be able to handle this itself
}

export default PowerShellLanguage;
