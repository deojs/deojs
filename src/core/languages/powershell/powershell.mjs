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
        parser.feed(inCode);
        console.log(parser.results);
        return {};
    }

    // parse function
    // parse function should handle lexing and actual parsing
    // lexing ideally should be a separate function so we can call it separately

    // pretty-print function, nearley should be able to handle this itself
}

export default PowerShellLanguage;
