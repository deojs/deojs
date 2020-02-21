/**
 * Worker to handle storage and processing of output
 */

// Object containing the output data and information
self.output = null;

/**
 * Handle messages sent by the main thread
 */
self.addEventListener("message", (e) => {
    if (!e.data) return;
    const data = e.data;

    if (!data.command) return;
    switch (data.command) {
    default:
        console.error(`Invalid command "${data.command}"`);
    }
});
