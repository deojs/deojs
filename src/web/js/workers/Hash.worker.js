/**
 * Worker to handle hashing
 */
import CryptoJS from "crypto-js";

self.addEventListener("message", (e) => {
    if (!e.data) return;
    const data = e.data;

    if (!data.command) return;
    switch (data.command) {
    case "hashArrayBuffer":
        self.postMessage({
            command: "callback",
            data: {
                callbackid: data.data.callbackId,
                data: self.hashArrayBuffer(data.data, data.data.algorithm)
            }
        });
        break;
    case "hash":
        self.postMessage({
            command: "callback",
            data: {
                callbackid: data.data.callbackId,
                data: self.hash(data.data, data.data.algorithm)
            }
        });
        break;
    default:
        console.error(`Unknown command "${data.command}"`);
    }
});

self.hashArrayBuffer = function (data, hashAlg) {
    const wordArray = CryptoJS.lib.WordArray.create(data);
    return self.hash(wordArray, hashAlg);
};

self.hash = function (data, hashAlg) {
    try {
        switch (hashAlg) {
        case "md5":
        case "MD5":
            return CryptoJS.MD5(data).toString();
        case "sha1":
        case "SHA1":
            return CryptoJS.SHA1(data).toString();
        case "sha256":
        case "SHA256":
            return CryptoJS.SHA256(data).toString();
        default:
            console.error(`Unknown hash algorithm ${hashAlg}`);
            return "";
        }
    } catch (error) {
        console.error(error);
        return "";
    }
};
