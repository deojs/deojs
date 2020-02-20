/**
 * Main worker for the entire App
 *
 * Handles communications between the main thread (UI) and the separate workers
 */

import LanguageHelper from "../helpers/LanguageHelper.mjs";

self.createHelpers = function () {
    self.LanguageHelper = new LanguageHelper();
};

/**
 * Handle messages sent by the main thread
 *
 * @param e - The message sent by the main thread
 */
self.addEventListener("message", (e) => {
    if (!e.data) return;
    const data = e.data;

    if (!data.command) return;
    console.log(data.command);
});

self.createHelpers();

// const ps = self.LanguageHelper.getLanguage("PowerShell");
// ps.lex("Get-ChildItem | Sort-Object -Property LastWriteTime, Name | Format-Table -Property LastWriteTime, Name");
