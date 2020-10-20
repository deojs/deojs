/**
 * Custom error class
 */
class CustomError extends Error {
    constructor(message) {
        super(message);
        this.name = "CustomError";
    }
}

export default CustomError;
