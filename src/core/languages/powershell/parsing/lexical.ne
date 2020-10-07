# Lexical grammar
input ->
    inputElements:? _ signatureBlock:?
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "input",
                data: out
            }
        }
    %}

inputElements ->
    (inputElement |
    inputElements inputElement)
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "inputElements",
                data: out
            }
        }
    %}

inputElement ->
    (whitespace |
    comment |
    token)
    {%
        function(data) {
            data = data[0];
            return {
                type: "inputElement",
                data: data[0]
            }
        }
    %}

signatureBlock ->
    signatureBegin _ signature _ signatureEnd
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "signatureBlock",
                data: out
            }
        }
    %}

signatureBegin ->
    newLineCharacter "# SIG # Begin signature block" newLineCharacter
    {%
        function(data) {
            return {
                type: "signatureBegin",
                data: data[0] + data[1] + data[2]
            }
        }
    %}

signature ->
    singleLineComments
    {%
        function(data) {
            return {
                type: "signature",
                data: data[0]
            }
        }
    %}

singleLineComments ->
    (singleLineComment |
    singleLineComments _ newLineCharacter _ singleLineComment)
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "singleLineComments",
                data: out
            }
        }
    %}

signatureEnd ->
    newLineCharacter "# SIG # End signature block" newLineCharacter
    {%
        function(data) {
            return {
                type: "signatureEnd",
                data: data[0] + data[1] + data[2]
            }
        }
    %}

# Line terminators
newLineCharacter ->
    (carriageReturnCharacter |
    lineFeedCharacter |
    carriageReturnCharacter lineFeedCharacter)
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "newLineCharacter",
                data: out
            }
        }
    %}

carriageReturnCharacter ->
    [\r]
    {% id %}

lineFeedCharacter ->
    [\n]
    {% id %}

newLines ->
    (newLineCharacter |
    newLines _ newLineCharacter)
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "newLines",
                data: out
            }
        }
    %}

# Comments
comment ->
    (singleLineComment |
    requiresComment |
    delimitedComment)
    {%
        function(data) {
            data = data[0];
            return {
                type: "comment",
                data: data[0]
            }
        }
    %}

singleLineComment ->
    "#" inputCharacters:? newLines
    {%
        function(data) {
            return {
                type: "singleLineComment",
                data: data
            }
        }
    %}

inputCharacters ->
    inputCharacter:+
    {%
        function(data) {
            return {
                type: "inputCharacters",
                data: data[0]
            }
        }
    %}

inputCharacter ->
    [^\r\n]
    {%
        function(data) {
            return {
                type: "inputCharacter",
                data: data[0]
            }
        }
    %}

requiresComment ->
    "#requires" __ commandArgument # Docs says commandArguments but might be a typo?
    {%
        function(data) {
            return {
                type: "requiresComment",
                data: data
            }
        }
    %}

dash ->
    ("\u002D" |
    "\u2013" |
    "\u2014" |
    "\u2015")
    {% id %}

dashdash ->
    dash dash
    {%
        function(data) {
            return {
                type: "dashdash",
                data: data[0] + data[1]
            }
        }
    %}

delimitedComment ->
    "<#" delimitedCommentText:? hashes ">"
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "delimitedComment",
                data: out
            }
        }
    %}

delimitedCommentText ->
    delimitedCommentSection:+
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "delimitedCommentText",
                data: out
            }
        }
    %}

delimitedCommentSection ->
    (">" |
    hashes:? notGreaterThanOrHash)
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "delimitedCommentSection",
                data: out
            }
        }
    %}

hashes ->
    ("#" |
    hashes "#")
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "hashes",
                data: out
            }
        }
    %}

notGreaterThanOrHash ->
    [^>#]
    {% id %}

whitespace ->
    ([\u0009\u000B\u000C] |
    Zs |
    Zl |
    Zp |
    "\u0060" newLineCharacter)
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "whitespace",
                data: out
            }
        }
    %}

token ->
    (keyword |
    variable |
    command |
    commandParameter |
    integerLiteral |
    realLiteral |
    stringLiteral |
    typeLiteral |
    operatorOrPunctuator)
    {%
        function(data) {
            data = data[0];
            return {
                type: "token",
                data: data[0]
            }
        }
    %}

keyword ->
    ("begin" | "break" | "catch" | "class" | "continue" | "data" |
    "define" | "do" | "dynamicparam" | "else" | "elseif" | "end" |
    "exit" | "filter" | "finally" | "for" | "foreach" | "from" |
    "function" | "if" | "in" | "inlinescript" | "parallel" | "param" |
    "process" | "return" | "switch" | "throw" | "trap" | "try" |
    "until" | "using" | "var" | "while" | "workflow")
    {%
        function(data) {
            data = data[0];
            return {
                type: "keyword",
                data: data[0]
            }
        }
    %}

variable ->
    ("$$" |
    "$?" |
    "$^" |
    "$" variableScope:? variableCharacters |
    "@" variableScope:? variableCharacters |
    bracedVariable)
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "variable",
                data: out
            }
        }
    %}

bracedVariable ->
    "${" _ variableScope:? _ bracedVariableCharacters _ "}"
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "bracedVariable",
                data: out
            }
        }
    %}

variableScope ->
    ("global:" |
    "local:" |
    "private:" |
    "script:" |
    "using:" |
    "workflow:" |
    variableNamespace)
    {%
        function(data) {
            data = data[0];
            return {
                type: "variableScope",
                data: data[0]
            }
        }
    %}

variableNamespace ->
    variableCharacters ":"
    {%
        function(data) {
            return {
                type: "variableNamespace",
                data: data
            }
        }
    %}

variableCharacters ->
    variableCharacter:+
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "variableCharacters",
                data: out
            }
        }
    %}

variableCharacter ->
    # This should include the unicode category 'Lo', however this has >120,000 characters so is too big
    (Llu |
    Lm |
    Nd |
    "\u005F" |
    "?")
    {%
        function(data) {
            data = data[0];
            return {
                type: "variableCharacter",
                data: data[0]
            }
        }
    %}

bracedVariableCharacters ->
    bracedVariableCharacter:+
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "bracedVariableCharacters",
                data: out
            }
        }
    %}

bracedVariableCharacter ->
    ([^\u007D\u0060] |
    escapedCharacter)
    {%
        function(data) {
            data = data[0];
            return {
                type: "bracedVariableCharacter",
                data: data[0]
            }
        }
    %}

escapedCharacter ->
    "\u0060" . # Any character
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "escapedCharacter",
                data: out
            }
        }
    %}

# Commands
genericToken ->
    genericTokenParts
    {%
        function(data) {
            return {
                type: "genericToken",
                data: data[0]
            }
        }
    %}

genericTokenParts ->
    firstGenericTokenPart genericTokenPart:*
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "genericTokenParts",
                data: out
            }
        }
    %}

firstGenericTokenPart ->
    (expandableStringLiteral |
    verbatimHereStringLiteral |
    variable |
    firstGenericTokenCharacter)
    {% id %}

genericTokenPart ->
    (expandableStringLiteral |
    verbatimHereStringLiteral |
    variable |
    genericTokenCharacter)
    {% id %}

genericTokenCharacter ->
    ([^{}();,|&$\u0060'"\r\n\s] |
    escapedCharacter)
    {% id %}

# Don't allow a hash at the start as then it would be a comment
firstGenericTokenCharacter ->
    ([^#{}();,|&$\u0060'"\r\n\s] |
    escapedCharacter)
    {% id %}

genericTokenWithSubexpressionStart ->
    genericTokenParts _ "$("
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "genericTokenWithSubexpressionStart",
                data: out
            }
        }
    %}

commandParameter ->
    dash firstParameterChar parameterChars colon:?
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "commandParameter",
                data: out
            }
        }
    %}

firstParameterChar ->
    (Llu |
    Lm |
    "\u005F" |
    "?")
    {% id %}

parameterChars ->
    parameterChar:+
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "parameterChars",
                data: out
            }
        }
    %}

parameterChar ->
    [^{}();,|&.[\u003A\r\n\s]
    {% id %}

colon ->
    "\u003A"
    {% id %}

verbatimCommandArgumentChars ->
    (verbatimCommandArgumentPart |
    verbatimCommandArgumentChars verbatimCommandArgumentPart)
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "verbatimCommandArgumentChars",
                data: out
            }
        }
    %}

verbatimCommandArgumentPart ->
    (verbatimCommandString |
    "&" nonAmpersandCharacter |
    [^|\r\n])
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "verbatimCommandArgumentPart",
                data: out
            }
        }
    %}

nonAmpersandCharacter ->
    [^&]
    {% id %}

verbatimCommandString ->
    doubleQuoteCharacter nonDoubleQuoteCharacters doubleQuoteCharacter
    {%
        function(data) {
            return {
                type: "verbatimCommandString",
                data: data
            }
        }
    %}

nonDoubleQuoteCharacters ->
    (nonDoubleQuoteCharacter |
    nonDoubleQuoteCharacters nonDoubleQuoteCharacter)
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "nonDoubleQuoteCharacters",
                data: out
            }
        }
    %}

nonDoubleQuoteCharacter ->
    [^\u0022\u201C\u201D\u201E]
    {% id %}

# Literals
literal ->
    (integerLiteral |
    realLiteral |
    stringLiteral)
    {% id %}

integerLiteral ->
    (decimalIntegerLiteral |
    hexadecimalIntegerLiteral)
    {% id %}

decimalIntegerLiteral ->
    decimalDigits numericTypeSuffix:? numericMultiplier:?
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "decimalIntegerLiteral",
                data: out
            }
        }
    %}

decimalDigits ->
    (decimalDigit |
    decimalDigit decimalDigits)
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "decimalDigits",
                data: out
            }
        }
    %}

decimalDigit ->
    [0-9]
    {% id %}

numericTypeSuffix ->
    (longTypeSuffix |
    decimalTypeSuffix)
    {%
        function(data) {
            data = data[0];
            return {
                type: "numericTypeSuffix",
                data: data[0]
            }
        }
    %}

hexadecimalIntegerLiteral ->
    "0x" hexadecimalDigits longTypeSuffix:? numericMultiplier:?
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "hexadecimalIntegerLiteral",
                data: out
            }
        }
    %}

hexadecimalDigits ->
    (hexadecimalDigit |
    hexadecimalDigit decimalDigits)
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "hexadecimalDigits",
                data: out
            }
        }
    %}

hexadecimalDigit ->
    [0-9A-Fa-f]
    {% id %}

longTypeSuffix ->
    "l"
    {%
        function(data) {
            return {
                type: "longTypeSuffix",
                data: data[0]
            }
        }
    %}

numericMultiplier ->
    ("kb" |
    "mb" |
    "gb" |
    "tb" |
    "pb")
    {%
        function(data) {
            data = data[0];
            return {
                type: "numericMultiplier",
                data: data[0]
            }
        }
    %}

realLiteral ->
    (decimalDigits "." decimalDigits exponentPart:? decimalTypeSuffix:? numericMultiplier:? |
    "." decimalDigits exponentPart:? decimalTypeSuffix:? numericMultiplier:? |
    decimalDigits exponentPart decimalTypeSuffix:? numericMultiplier:?)
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "realLiteral",
                data: out
            }
        }
    %}

exponentPart ->
    "e" sign:? decimalDigits
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "exponentPart",
                data: out
            }
        }
    %}

sign ->
    ("+" |
    dash)
    {%
        function(data) {
            data = data[0];
            return {
                type: "sign",
                data: data[0]
            }
        }
    %}

decimalTypeSuffix ->
    ("d" |
    "l")
    {%
        function(data) {
            data = data[0];
            return {
                type: "decimalTypeSuffix",
                data: data[0]
            }
        }
    %}

stringLiteral ->
    (expandableStringLiteral |
    expandableHereStringLiteral |
    verbatimStringLiteral |
    verbatimHereStringLiteral)
    {%
        function(data) {
            data = data[0];
            return {
                type: "stringLiteral",
                data: data[0]
            }
        }
    %}

expandableStringLiteral ->
    doubleQuoteCharacter expandableStringCharacters:? dollars:? doubleQuoteCharacter
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "expandableStringLiteral",
                data: out
            }
        }
    %}

doubleQuoteCharacter ->
    ("\u0022" |
    "\u201C" |
    "\u201D" |
    "\u201E")
    {% id %}

expandableStringCharacters ->
    expandableStringPart:+
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "expandableStringCharacters",
                data: out
            }
        }
    %}

expandableStringPart ->
    ([^$\u0022\u201C\u201D\u201E\u0060] |
    bracedVariable |
    "$" [^({\u0022\u201C\u201D\u201E\u0060] |
    "$" escapedCharacter |
    escapedCharacter |
    doubleQuoteCharacter doubleQuoteCharacter)
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "expandableStringPart",
                data: out
            }
        }
    %}

dollars ->
    "$":+
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "dollars",
                data: out
            }
        }
    %}

expandableHereStringLiteral ->
    "@" doubleQuoteCharacter _ newLineCharacter expandableHereStringCharacters:? newLineCharacter doubleQuoteCharacter "@"
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "expandableHereStringLiteral",
                data: out
            }
        }
    %}

expandableHereStringCharacters ->
    expandableHereStringPart:+
    {%
        function(data) {
            return {
                type: "expandableHereStringCharacters",
                data: data[0]
            }
        }
    %}

expandableHereStringPart ->
    ([^$\r\n] |
    bracedVariable |
    "$" [^(\r\n] |
    "$" newLineCharacter nonDoubleQuoteCharacter |
    "$" newLineCharacter doubleQuoteCharacter [^@] |
    newLineCharacter nonDoubleQuoteCharacter |
    newLineCharacter doubleQuoteCharacter [^@])
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "expandableHereStringPart",
                data: out
            }
        }
    %}

expandableStringWithSubexpressionStart ->
    doubleQuoteCharacter expandableStringCharacters:? "$("
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "expandableStringWithSubexpressionStart",
                data: out
            }
        }
    %}

expandableStringWithSubexpressionEnd ->
    doubleQuoteCharacter
    {%
        function(data) {
            return {
                type: "expandableStringWithSubexpressionEnd",
                data: data[0]
            }
        }
    %}

expandableHereStringWithSubexpressionStart ->
    "@" doubleQuoteCharacter _ newLineCharacter expandableHereStringCharacters:? "$("
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "expandableHereStringWithSubexpressionStart",
                data: out
            }
        }
    %}

expandableHereStringWithSubexpressionEnd ->
    newLineCharacter doubleQuoteCharacter "@"
    {%
        function(data) {
            return {
                type: "expandableHereStringWithSubexpressionEnd",
                data: data
            }
        }
    %}

verbatimStringLiteral ->
    singleQuoteCharacter verbatimStringCharacters:? singleQuoteCharacter
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "verbatimStringLiteral",
                data: out
            }
        }
    %}

singleQuoteCharacter ->
    ("\u0027" |
    "\u2018" |
    "\u2019" |
    "\u201A" |
    "\u201B")
    {% id %}

nonSingleQuoteCharacter ->
    [^\u0027\u2018\u2019\u201A\u201B]
    {% id %}

verbatimStringCharacters ->
    verbatimStringPart:+
    {%
        function(data) {
            return {
                type: "verbatimStringCharacters",
                data: data[0]
            }
        }
    %}

verbatimStringPart ->
    (nonSingleQuoteCharacter |
    singleQuoteCharacter singleQuoteCharacter)
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "verbatimStringPart",
                data: out
            }
        }
    %}

verbatimHereStringLiteral ->
    "@" singleQuoteCharacter _ newLineCharacter verbatimHereStringCharacters:? newLineCharacter singleQuoteCharacter "@"
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "verbatimHereStringLiteral",
                data: out
            }
        }
    %}

verbatimHereStringCharacters ->
    verbatimHereStringPart:+
    {%
        function(data) {
            return {
                type: "verbatimHereStringCharacters",
                data: data[0]
            }
        }
    %}

verbatimHereStringPart ->
    ([^\r\n] |
    newLineCharacter nonSingleQuoteCharacter |
    newLineCharacter singleQuoteCharacter [^@])
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "verbatimHereStringPart",
                data: out
            }
        }
    %}

simpleName ->
    simpleNameFirstChar simpleNameChars
    {%
        function(data) {
            return {
                type: "simpleName",
                data: data
            }
        }
    %}

simpleNameFirstChar ->
    (Llu |
    Lm |
    "\u005F")
    {% id %}

simpleNameChars ->
    simpleNameChar:+
    {%
        function(data) {
            return {
                type: "simpleNameChars",
                data: data[0]
            }
        }
    %}

simpleNameChar ->
    (Llu |
    Lm |
    Nd |
    "\u005F")
    {% id %}

typeName ->
    (typeIdentifier |
    typeName "." typeIdentifier)
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "typeName",
                data: out
            }
        }
    %}

typeIdentifier ->
    typeCharacter:+
    {%
        function(data) {
            return {
                type: "typeIdentifier",
                data: data[0]
            }
        }
    %}

typeCharacter ->
    (Llu |
    Nd |
    "\u005F")
    {% id %}

arrayTypeName ->
    typeName "["
    {%
        function(data) {
            return {
                type: "arrayTypeName",
                data: data
            }
        }
    %}

genericTypeName ->
    typeName "["
    {%
        function(data) {
            return {
                type: "genericTypeName",
                data: data
            }
        }
    %}

operatorOrPunctuator ->
    ("{" | "}" | "[" | "]" | "(" | ")" | "@(" | "@{" | "$(" | ";" |
    "&&" | "||" | "&" | "|" | "," | "++" | ".." | "::" | "." | "!" |
    "*" | "/" | "%" | "+" |
    dash | dashdash | dash "and" | dash "band" | dash "bnot" |
    dash "bor" | dash "bxor" | dash "not" | dash "or" | dash "xor" |
    assignmentOperator |
    mergingRedirectionOperator |
    fileRedirectionOperator |
    comparisonOperator |
    formatOperator)
    {% id %}

assignmentOperator ->
    ("=" |
    dash "=" |
    "+=" |
    "*=" |
    "/=" |
    "%=")
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "assignmentOperator",
                data: out
            }
        }
    %}

mergingRedirectionOperator ->
    ("*>&1" | "2>&1" | "3>&1" | "4>&1" | "5>&1" | "6>&1" |
    "*>&2" | "1>&2" | "3>&2" | "4>&2" | "5>&2" | "6>&2")
    {%
        function(data) {
            data = data[0];
            return {
                type: "mergingRedirectionOperator",
                data: data[0]
            }
        }
    %}

fileRedirectionOperator ->
    (">" | ">>" | "2>" | "2>>" | "3>" | "3>>" | "4>" | "4>>" |
    "5>" | "5>>" | "6>" | "6>>" | "*>" | "*>>" | "<")
    {%
        function(data) {
            data = data[0];
            return {
                type: "fileRedirectionOperator",
                data: data[0]
            }
        }
    %}

comparisonOperator ->
    dash comparisonKeyword
    {%
        function(data) {
            return {
                type: "comparisonOperator",
                data: data
            }
        }
    %}

comparisonKeyword ->
    ("as" | "ccontains" | "ceq" | "cge" | "cgt" | "cle" | "clike" | "clt" |
    "cmatch" | "cne"| "cnotcontains" | "cnotlike" | "cnotmatch" | "contains" |
    "creplace" | "csplit" | "eq" | "ge" | "gt" | "icontains" | "ieq" | "ige" |
    "igt" | "ile" | "ilike" | "ilt" | "imatch" | "in" | "ine" | "inotcontains" |
    "inotlike" | "inotmatch" | "ireplace" | "is" | "isnot" | "isplit" |
    "join" | "le" | "like" | "lt" | "match" | "ne" | "notcontains" | "notin" |
    "notlike" | "notmatch" | "replace" | "shl" | "shr" | "split")
    {%
        function(data) {
            data = data[0];
            return {
                type: "comparisonKeyword",
                data: data[0]
            }
        }
    %}

formatOperator ->
    dash "f"
    {%
        function(data) {
            return {
                type: "formatOperator",
                data: data
            }
        }
    %}

# Whitespace
_ -> __:?
    {% id %}
__ -> whitespace:+
    {%
        function(data) {
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined) {
                    out.push(data[i]);
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "whitespace",
                data: out
            }
        }
    %}
