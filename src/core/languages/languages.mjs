/**
 * Handles the importing of all languages
 */

// Language imports
import PowerShellLanguage from "./powershell/powershell.mjs";

class Languages {
    constructor() {
        this.languages = {};

        // Create Object containing all languages so we can refer to them by name
        this.languages.powershell = PowerShellLanguage;
    }

    /**
     * Creates a new instance of a language class and returns it
     *
     * @param {string} langName The name of the language
     * @returns {object} - The language class
     */
    getLanguage(langName) {
        const lowerName = langName.toLowerCase();
        if (this.languages[lowerName] !== undefined) {
            return this.languages[lowerName];
        }
        throw Error(`Language "${langName}" does not exist!`);
    }
}

export default Languages;
