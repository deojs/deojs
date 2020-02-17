/**
 * Main worker for the entire App
 *
 * Handles communications between the main thread (UI) and the separate workers
 */

/**
 * Handle messages sent by the main thread
 *
 * @param e - The message sent by the main thread
 */
self.addEventListener("message", (e) => {
    if (!e.data) return;
    const data = e.data;

    console.log(data);
});
