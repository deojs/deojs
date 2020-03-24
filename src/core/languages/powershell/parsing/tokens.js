import moo from "moo";

const tokens = {
    newLineCharacter: {
        match: /(?:[\u000D\u000A]|[\u000D][\u000A])/
    },
    newLines: {
        match: /(?:[\u000D\u000A]|[\u000D][\u000A])+/
    },
    singleLineComment: {
        match: /[#](?:[^\u000D\u000A]|[\u000D][\u000A])*/
    },
    delimitedComment: {
        match: /<#(?:[>]|#*[^>#])/
    },
    dash: {
        match: /[\u002D\u2013\u2014\u2015]/
    },
    dashdash: {
        match: /[\u002D\u2013\u2014\u2015]{2}/
    },
    whitespace: {
        match: /(?:[\s\u0009\u000B\u000C]|[\u0060](?:[\u000D\u000A]|[\u000D][\u000A]))/
    }
};

export default tokens;
