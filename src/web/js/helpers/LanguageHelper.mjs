/**
 * Helper to handle language-related functions
 */

import Languages from "../../../core/languages/languages.mjs";

class LanguageHelper {
    constructor() {
        this.languages = new Languages();
    }

    /**
     * Gets a new instance of the class for the specified language
     *
     * @param {string} langName The name of the language
     * @returns {object} language class
     */
    getLanguage(langName) {
        const Language = this.languages.getLanguage(langName);
        return new Language();
    }
}

export default LanguageHelper;
