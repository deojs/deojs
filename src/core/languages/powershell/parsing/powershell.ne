# Powershell grammar
# From https://www.microsoft.com/en-us/download/details.aspx?id=36389

@include "../../unicode/categories/unicode_Zs.ne"
@include "../../unicode/categories/unicode_Zl.ne"
@include "../../unicode/categories/unicode_Zp.ne"
@include "../../unicode/categories/unicode_Llu.ne"
@include "../../unicode/categories/unicode_Lm.ne"
# @include "../../unicode/categories/unicode_Lo.ne" # Can't import this as it's too big!
@include "../../unicode/categories/unicode_Nd.ne"

# Syntactic grammar
main ->
    scriptBlock |
    statementList

# Statements
scriptBlock ->
    paramBlock:? statementTerminators:? scriptBlockBody:?

paramBlock ->
    newLines:? attributeList:? newLines:? "param" newLines:?
        "(" parameterList:? newLines:? ")"

parameterList ->
    scriptParameter parameterList newLines:? "," scriptParameter

scriptParameter ->
    newLines:? attributeList:? newLines:? variable scriptParameterDefault:?

scriptParameterDefault ->
    newLines:? "=" newLines:? expression

scriptBlockBody ->
    namedBlockList |
    statementList

namedBlockList ->
    namedBlock |
    namedBlockList namedBlock

namedBlock ->
    blockName statementBlock statementTerminators:?

blockName ->
    "dynamicparam"i |
    "begin"i |
    "process"i |
    "end"i

statementBlock ->
    newLines:? "{" statementList:? newLines:? "}"

statementList ->
    statement |
    statementList statement

statement ->
    ifStatement |
    label:? labeledStatement |
    functionStatement |
    flowControlStatement statementTerminator |
    trapStatement |
    tryStatement |
    dataStatement |
    inlinescriptStatement |
    parallelStatement |
    sequenceStatement |
    pipeline statementTerminator

statementTerminator ->
    ";" |
    newLineCharacter

statementTerminators ->
    statementTerminator |
    statementTerminators statementTerminator

ifStatement ->
    "if"i newLines:? "(" newLines:? pipeline newLines:? ")" statementBlock
        elseifClauses:? elseClause:?

elseifClauses ->
    elseifClause |
    elseifClauses elseifClause

elseifClause ->
    newLines:? "elseif"i newLines:? "(" newLines:? pipeline newLines:? ")" statementBlock

elseClause ->
    newLines:? "else"i statementBlock

label ->
    colon labelExpression

labeledStatement ->
    switchStatement |
    foreachStatement |
    forStatement |
    whileStatement |
    doStatement

switchStatement ->
    "switch"i newLines:? switchParameters:? switchCondition switchBody

switchParameters ->
    switchParameter |
    switchParameters switchParameter

switchParameter ->
    "-regex"i |
    "-wildcard"i |
    "-exact"i |
    "-casesensitive"i |
    "-parallel"i

switchCondition ->
    "(" newLines:? pipeline newLines:? ")" |
    "-file"i newLines:? switchFilename

switchFilename ->
    commandArgument |
    primaryExpression

switchBody ->
    newLines :? "{" newLines:? switchClauses "}"

switchClauses ->
    switchClause |
    switchClauses switchClause

switchClause ->
    switchClauseCondition statementBlock statementTerminators:?

switchClauseCondition ->
    commandArgument |
    primaryExpression

foreachStatement ->
    "foreach"i newLines:? foreachParameter:? newLines:?
        "(" newLines:? variable newLines:? "in"i newLines:? pipeline
        newLines:? ")" statementBlock

foreachParameter ->
    "-parallel"i

forStatement ->
    "for"i newLines:? (
        "(" newLines:? forInitializer:? statementTerminator
        newLines:? forCondition:? statementTerminator
        newLines:? forIterator:? newLines:? ")" statementBlock |
        "(" newLines:? forInitializer:? statementTerminator
        newLines:? forCondition:? newLines:? ")" statementBlock |
        "(" newLines:? forInitializer:? newLines:? ")" statementBlock
    )

forInitializer->
    pipeline

forCondition ->
    pipeline

forIterator ->
    pipeline

whileStatement ->
    "while"i newLines:? "(" newLines:? whileCondition newLines:? ")" statementBlock

doStatement ->
    "do"i statementBlock newLines:? "while"i newLines:? "(" whileCondition newLines:? ")" |
    "do"i statementBlock newLines:? "until"i newLines:? "(" whileCondition newLines:? ")"

whileCondition ->
    newLines:? pipeline

functionStatement ->
    "function"i newLines:? functionName functionParameterDeclaration:? "{" scriptBlock "}" |
    "filter"i newLines:? functionName functionParameterDeclaration:? "{" scriptBlock "}" |
    "workflow"i newLines:? functionName functionParameterDeclaration:? "{" scriptBlock "}"

functionName ->
    commandArgument

functionParameterDeclaration ->
    newLines:? "(" parameterList newLines:? ")"

flowControlStatement ->
    "break"i labelExpression:? |
    "continue"i labelExpression:? |
    "throw"i pipeline:? |
    "return"i pipeline:? |
    "exit"i pipeline:?

labelExpression ->
    simpleName |
    unaryExpression

trapStatement ->
    "trap"i newLines:? typeLiteral:? newLines:? statementBlock

tryStatement ->
    "try"i statementBlock catchClauses |
    "try"i statementBlock finallyClause |
    "try"i statementBlock catchClauses finallyClause

catchClauses ->
    catchClause |
    catchClauses catchClause

catchClause ->
    newLines:? "catch"i catchTypeList:? statementBlock

catchTypeList ->
    newLines:? typeLiteral |
    catchTypeList newLines:? "," newLines:? typeLiteral

finallyClause ->
    newLines:? "finally"i statementBlock

dataStatement ->
    "data"i newLines:? dataName dataCommandsAllowed:? statementBlock

dataName ->
    simpleName

dataCommandsAllowed ->
    newLines:? "-supportedcommand"i dataCommandsList

dataCommandsList ->
    newLines:? dataCommand |
    dataCommandsList "," newLines:? dataCommand

dataCommand ->
    commandNameExpression

inlinescriptStatement ->
    "inlinescript"i statementBlock

parallelStatement ->
    "parallel"i statementBlock

sequenceStatement ->
    "sequence"i statementBlock

pipeline ->
    assignmentExpression |
    expression redirections:? pipelineTail:? |
    command verbatimCommandArgument:? pipelineTail:?

assignmentExpression ->
    expression assignmentOperator statement

pipelineTail ->
    "|" newLines:? command |
    "|" newLines:? command pipelineTail

command ->
    commandName commandElements:? |
    commandInvocationOperator commandModule:? commandNameExpression commandElements:?

commandInvocationOperator ->
    "&" |
    "."

commandModule ->
    primaryExpression

commandName ->
    genericToken |
    genericTokenWithSubexpression

genericTokenWithSubexpression ->
    genericTokenWithSubexpressionStart statementList:? ")" commandName # No whitespace between ) and commandName!

commandNameExpression ->
    commandName |
    primaryExpression

commandElements ->
    commandElement |
    commandElements commandElement

commandElement ->
    commandParameter |
    commandArgument |
    redirection

commandArgument ->
    commandNameExpression

verbatimCommandArgument ->
    "--%" verbatimCommandArgumentChars

redirections ->
    redirection |
    redirections redirection

redirection ->
    mergingRedirectionOperator |
    fileRedirectionOperator redirectedFileName

redirectedFileName ->
    commandArgument |
    primaryExpression

# Expressions
expression ->
    logicalExpression

logicalExpression ->
    bitwiseExpression |
    logicalExpression "-and"i newLines:? bitwiseExpression |
    logicalExpression "-or"i newLines:? bitwiseExpression |
    logicalExpression "-xor"i newLines:? bitwiseExpression

bitwiseExpression ->
    comparisonExpression |
    bitwiseExpression "-band" newLines:? comparisonExpression |
    bitwiseExpression "-bor" newLines:? comparisonExpression |
    bitwiseExpression "-bxor" newLines:? comparisonExpression

comparisonExpression ->
    additiveExpression |
    comparisonExpression comparisonOperator newLines:? additiveExpression

additiveExpression ->
    multiplicativeExpression |
    additiveExpression "+" newLines:? multiplicativeExpression |
    additiveExpression dash newLines:? multiplicativeExpression

multiplicativeExpression ->
    formatExpression |
    multiplicativeExpression "*" newLines:? formatExpression |
    multiplicativeExpression "/" newLines:? formatExpression |
    multiplicativeExpression "%" newLines:? formatExpression

formatExpression ->
    rangeExpression |
    formatExpression formatOperator newLines:? rangeExpression

rangeExpression ->
    arrayLiteralExpression |
    rangeExpression ".." newLines:? arrayLiteralExpression

arrayLiteralExpression ->
    unaryExpression |
    unaryExpression "," newLines:? arrayLiteralExpression

unaryExpression ->
    primaryExpression |
    expressionWithUnaryOperator

expressionWithUnaryOperator ->
    "," newLines:? unaryExpression |
    "-not"i newLines:? unaryExpression |
    "!" newLines:? unaryExpression |
    "-bnot"i newLines:? unaryExpression |
    "+" newLines:? unaryExpression |
    dash newLines:? unaryExpression |
    preIncrementExpression |
    preDecrementExpression |
    castExpression |
    "-split"i newLines:? unaryExpression |
    "-join"i newLines:? unaryExpression

preIncrementExpression ->
    "++" newLines:? unaryExpression

preDecrementExpression ->
    dashdash newLines:? unaryExpression

castExpression ->
    typeLiteral unaryExpression

attributedExpression ->
    typeLiteral variable

primaryExpression ->
    value |
    memberAccess |
    elementAccess |
    invocationExpression |
    postIncrementExpression |
    postDecrementExpression

value ->
    parenthesizedExpression |
    subExpression |
    arrayExpression |
    scriptBlockExpression |
    hashLiteralExpression |
    literal |
    typeLiteral |
    variable

parenthesizedExpression ->
    "(" newLines:? pipeline newLines:? ")"

subExpression ->
    "$(" newLines:? statementList:? newLines:? ")"

arrayExpression ->
    "@(" newLines:? statementList:? newLines:? ")"

scriptBlockExpression ->
    "{" newLines:? scriptBlock newLines:? "}"

hashLiteralExpression ->
    "@{" newLines:? hashLiteralBody:? newLines:? "}"

hashLiteralBody ->
    hashEntry |
    hashLiteralBody statementTerminators hashEntry

hashEntry ->
    keyExpression "=" newLines:? statement

keyExpression ->
    simpleName |
    unaryExpression

postIncrementExpression ->
    primaryExpression "++"

postDecrementExpression ->
    primaryExpression dashdash

memberAccess -> # No whitespace after primaryExpression
    primaryExpression "." memberName |
    primaryExpression "::" memberName

elementAccess -> # No whitespace between primaryExpression and "["
    primaryExpression "[" newLines:? expression newLines:? "]"

invocationExpression -> # No whitespace after primaryExpression
    primaryExpression "." memberName argumentList |
    primaryExpression "::" memberName argumentList

argumentList ->
    "(" argumentExpressionList:? newLines:? ")"

argumentExpressionList ->
    argumentExpression |
    argumentExpression newLines:? "," argumentExpressionList

argumentExpression ->
    newLines:? logicalArgumentExpression

logicalArgumentExpression ->
    bitwiseArgumentExpression |
    logicalArgumentExpression "-and"i newLines:? bitwiseArgumentExpression |
    logicalArgumentExpression "-or"i newLines:? bitwiseArgumentExpression |
    logicalArgumentExpression "-xor"i newLines:? bitwiseArgumentExpression

bitwiseArgumentExpression ->
    comparisonArgumentExpression |
    bitwiseArgumentExpression "-band"i newLines:? comparisonArgumentExpression |
    bitwiseArgumentExpression "-bor"i newLines:? comparisonArgumentExpression |
    bitwiseArgumentExpression "-bxor"i newLines:? comparisonArgumentExpression

comparisonArgumentExpression ->
    additiveArgumentExpression |
    comparisonArgumentExpression comparisonOperator newLines:? additiveArgumentExpression

additiveArgumentExpression ->
    multiplicativeArgumentExpression |
    additiveArgumentExpression "+" newLines:? multiplicativeArgumentExpression |
    additiveArgumentExpression dash newLines:? multiplicativeArgumentExpression

multiplicativeArgumentExpression ->
    formatArgumentExpression |
    multiplicativeArgumentExpression "*" newLines:? formatArgumentExpression |
    multiplicativeArgumentExpression "/" newLines:? formatArgumentExpression |
    multiplicativeArgumentExpression "%" newLines:? formatArgumentExpression

formatArgumentExpression ->
    rangeArgumentExpression |
    formatArgumentExpression formatOperator newLines:? rangeArgumentExpression

rangeArgumentExpression ->
    unaryExpression |
    rangeExpression ".." newLines:? unaryExpression

memberName ->
    simpleName |
    stringLiteral |
    stringLiteralWithSubexpression |
    expressionWithUnaryOperator |
    value

stringLiteralWithSubexpression ->
    expandableStringLiteralWithSubexpression

expandableStringLiteralWithSubexpression ->
    expandableStringWithSubexpressionStart statementList:? ")" expandableStringWithSubexpressionChars expandableStringWithSubexpressionEnd |
    expandableHereStringWithSubexpressionStart statementList:? ")" expandableHereStringWithSubexpressionChars expandableHereStringWithSubexpressionEnd

expandableStringWithSubexpressionChars ->
    expandableStringWithSubexpressionPart |
    expandableStringWithSubexpressionChars expandableStringWithSubexpressionPart

expandableStringWithSubexpressionPart ->
    subExpression |
    expandableStringWithSubexpressionPart

expandableHereStringWithSubexpressionChars ->
    expandableHereStringWithSubexpressionPart |
    expandableHereStringWithSubexpressionChars expandableHereStringWithSubexpressionPart

expandableHereStringWithSubexpressionPart ->
    subExpression |
    expandableHereStringPart

typeLiteral ->
    "[" typeSpec "]"

typeSpec ->
    arrayTypeName newLines:? dimension:? "]" |
    genericTypeName newLines:? genericTypeArguments "]" |
    typeName

dimension ->
    "," |
    dimension ","

genericTypeArguments ->
    typeSpec newLines:? |
    genericTypeArguments "," newLines:? typeSpec

# Attributes
attributeList ->
    attribute |
    attributeList newLines:? attribute

attribute ->
    "[" newLines:? attributeName "(" attributeArguments newLines:? ")" newLines:? "]" |
    typeLiteral

attributeName ->
    typeSpec

attributeArguments ->
    attributeArgument |
    attributeArgument newLines:? "," attributeArguments

attributeArgument ->
    newLines:? expression |
    newLines:? simpleName |
    newLines:? simpleName "=" newLines:? expression

# Lexical grammar
input ->
    inputElements:? signatureBlock:?

inputElements ->
    inputElement |
    inputElements inputElement

inputElement ->
    whitespace |
    comment |
    token

signatureBlock ->
    signatureBegin signature signatureEnd

signatureBegin ->
    newLineCharacter "# SIG # Begin signature block" newLineCharacter

signature ->
    singleLineComments

singleLineComments ->
    singleLineComment |
    singleLineComments newLineCharacter singleLineComment

signatureEnd ->
    newLineCharacter "# SIG # End signature block" newLineCharacter

# Line terminators
newLineCharacter ->
    carriageReturnCharacter |
    lineFeedCharacter |
    carriageReturnCharacter lineFeedCharacter

carriageReturnCharacter ->
    [\r]

lineFeedCharacter ->
    [\n]

newLines ->
    newLineCharacter |
    newLines newLineCharacter

# Comments
comment ->
    singleLineComment |
    requiresComment |
    delimitedComment

singleLineComment ->
    "#" inputCharacters:?

inputCharacters ->
    inputCharacter |
    inputCharacters inputCharacter

inputCharacter ->
    [^\r\n]

requiresComment ->
    "#requires" whitespace commandArgument # Docs says commandArguments but might be a typo?

dash ->
    "\u002D" |
    "\u2013" |
    "\u2014" |
    "\u2015"

dashdash ->
    dash dash

delimitedComment ->
    "<#" delimitedCommentText:? hashes ">"

delimitedCommentText ->
    delimitedCommentSection |
    delimitedCommentText delimitedCommentSection

delimitedCommentSection ->
    ">" |
    hashes:? notGreatedThanOrHash

hashes ->
    "#" |
    hashes "#"

notGreatedThanOrHash ->
    [^>#]

whitespace ->
    "\u2028" |
    "\u2029" |
    "\u0009" |
    "\u000B" |
    "\u000C" |
    Zs |
    Zl |
    Zp |
    "`" newLineCharacter

token ->
    keyword |
    variable |
    command |
    commandParameter |
    # commandArgumentToken |
    integerLiteral |
    realLiteral |
    stringLiteral |
    typeLiteral |
    operatorOrPunctuator

keyword ->
    "begin" | "break" | "catch" | "class" | "continue" | "data" |
    "define" | "do" | "dynamicparam" | "else" | "elseif" | "end" |
    "exit" | "filter" | "finally" | "for" | "foreach" | "from" |
    "function" | "if" | "in" | "inlinescript" | "parallel" | "param" |
    "process" | "return" | "switch" | "throw" | "trap" | "try" |
    "until" | "using" | "var" | "while" | "workflow"

variable ->
    "$$" |
    "$?" |
    "$^" |
    "$" variableScope:? variableCharacters |
    "@" variableScope:? variableCharacters |
    bracedVariable

bracedVariable ->
    "${" variableScope:? bracedVariableCharacters "}"

variableScope ->
    "global:" |
    "local:" |
    "private:" |
    "script:" |
    "using:" |
    "workflow:" |
    variableNamespace

variableNamespace ->
    variableCharacters ":"

variableCharacters ->
    variableCharacter |
    variableCharacters variableCharacter

variableCharacter ->
    # This should include the unicode category 'Lo', however this has >120,000 characters so is too big
    Llu |
    Lm |
    Nd |
    "\u005F" |
    "?"
bracedVariableCharacters ->
    bracedVariableCharacter |
    bracedVariableCharacters bracedVariableCharacter

bracedVariableCharacter ->
    [^\u007D\u0060] |
    escapedCharacter

escapedCharacter ->
    "\u0060" . # Any character

# Commands
genericToken ->
    genericTokenParts

genericTokenParts ->
    genericTokenPart |
    genericTokenParts genericTokenPart

genericTokenPart ->
    expandableStringLiteral |
    verbatimHereStringLiteral |
    variable |
    genericTokenCharacter

genericTokenCharacter ->
    [^{}();,|&$\u0060'"\r\n] |
    escapedCharacter

genericTokenWithSubexpressionStart ->
    genericTokenParts "$("

commandParameter ->
    dash firstParameterChar parameterChars colon:?

firstParameterChar ->
    Llu |
    Lm |
    "\u005F" |
    "?"

parameterChars ->
    parameterChar |
    parameterChars parameterChar

parameterChar ->
    [^{}();,|&.[\u003A\r\n\s]

colon ->
    "\u003A"

verbatimCommandArgumentChars ->
    verbatimCommandArgumentPart |
    verbatimCommandArgumentChars verbatimCommandArgumentPart

verbatimCommandArgumentPart ->
    verbatimCommandString |
    "&" nonAmpersandCharacter |
    [^|\r\n]

nonAmpersandCharacter ->
    [^&]

verbatimCommandString ->
    doubleQuoteCharacter nonDoubleQuoteCharacters doubleQuoteCharacter

nonDoubleQuoteCharacters ->
    nonDoubleQuoteCharacter |
    nonDoubleQuoteCharacters nonDoubleQuoteCharacter

nonDoubleQuoteCharacter ->
    [^\u0022\u201C\u201D\u201E]

# Literals
literal ->
    integerLiteral |
    realLiteral |
    stringLiteral

integerLiteral ->
    decimalIntegerLiteral |
    hexadecimalIntegerLiteral

decimalIntegerLiteral ->
    decimalDigits numericTypeSuffix:? numericMultiplier:?

decimalDigits ->
    decimalDigit |
    decimalDigit decimalDigits

decimalDigit ->
    [0-9]

numericTypeSuffix ->
    longTypeSuffix |
    decimalTypeSuffix

hexadecimalIntegerLiteral ->
    "0x" hexadecimalDigits longTypeSuffix:? numericMultiplier:?

hexadecimalDigits ->
    hexadecimalDigit |
    hexadecimalDigit decimalDigits

hexadecimalDigit ->
    [0-9A-Fa-f]

longTypeSuffix ->
    "l"

numericMultiplier ->
    "kb" |
    "mb" |
    "gb" |
    "tb" |
    "pb"

realLiteral ->
    decimalDigits "." decimalDigits exponentPart:? decimalTypeSuffix:? numericMultiplier:? |
    "." decimalDigits exponentPart:? decimalTypeSuffix:? numericMultiplier:? |
    decimalDigits exponentPart decimalTypeSuffix:? numericMultiplier:?

exponentPart ->
    "e" sign:? decimalDigits

sign ->
    "+" |
    dash

decimalTypeSuffix ->
    "d" |
    "l"

stringLiteral ->
    expandableStringLiteral |
    expandableHereStringLiteral |
    verbatimStringLiteral |
    verbatimHereStringLiteral

expandableStringLiteral ->
    doubleQuoteCharacter expandableStringCharacters:? dollars:? doubleQuoteCharacter

doubleQuoteCharacter ->
    "\u0022" |
    "\u201C" |
    "\u201D" |
    "\u201E"

expandableStringCharacters ->
    expandableStringPart |
    expandableStringCharacters expandableStringPart

expandableStringPart ->
    [^$\u0022\u201C\u201D\u201E\u0060] |
    bracedVariable |
    "$" [^({\u0022\u201C\u201D\u201E\u0060] |
    "$" escapedCharacter |
    escapedCharacter |
    doubleQuoteCharacter doubleQuoteCharacter

dollars ->
    "$" |
    dollars "$"

expandableHereStringLiteral ->
    "@" doubleQuoteCharacter whitespace:? newLineCharacter expandableHereStringCharacters:? newLineCharacter doubleQuoteCharacter "@"

expandableHereStringCharacters ->
    expandableHereStringPart |
    expandableHereStringCharacters expandableHereStringPart

expandableHereStringPart ->
    [^$\r\n] |
    bracedVariable |
    "$" [^(\r\n] |
    "$" newLineCharacter nonDoubleQuoteCharacter |
    "$" newLineCharacter doubleQuoteCharacter [^@] |
    newLineCharacter nonDoubleQuoteCharacter |
    newLineCharacter doubleQuoteCharacter [^@]

expandableStringWithSubexpressionStart ->
    doubleQuoteCharacter expandableStringCharacters:? "$("

expandableStringWithSubexpressionEnd ->
    doubleQuoteCharacter

expandableHereStringWithSubexpressionStart ->
    "@" doubleQuoteCharacter whitespace:? newLineCharacter expandableHereStringCharacters:? "$("

expandableHereStringWithSubexpressionEnd ->
    newLineCharacter doubleQuoteCharacter "@"

verbatimStringLiteral ->
    singleQuoteCharacter verbatimStringCharacters:? singleQuoteCharacter

singleQuoteCharacter ->
    "\u0027" |
    "\u2018" |
    "\u2019" |
    "\u201A" |
    "\u201B"

nonSingleQuoteCharacter ->
    [^\u0027\u2018\u2019\u201A\u201B]

verbatimStringCharacters ->
    verbatimStringPart |
    verbatimStringCharacters verbatimStringPart

verbatimStringPart ->
    nonSingleQuoteCharacter |
    singleQuoteCharacter singleQuoteCharacter

verbatimHereStringLiteral ->
    "@" singleQuoteCharacter whitespace:? newLineCharacter verbatimHereStringCharacters:? newLineCharacter singleQuoteCharacter "@"

verbatimHereStringCharacters ->
    verbatimHereStringPart |
    verbatimHereStringCharacters verbatimHereStringPart

verbatimHereStringPart ->
    [^\r\n] |
    newLineCharacter nonSingleQuoteCharacter |
    newLineCharacter singleQuoteCharacter [^@]

simpleName ->
    simpleNameFirstChar simpleNameChars

simpleNameFirstChar ->
    Llu |
    Lm |
    "\u005F"

simpleNameChars ->
    simpleNameChar |
    simpleNameChars simpleNameChar

simpleNameChar ->
    Llu |
    Lm |
    Nd |
    "\u005F"

typeName ->
    typeIdentifier |
    typeName "." typeIdentifier

typeIdentifier ->
    typeCharacters

typeCharacters ->
    typeCharacter |
    typeCharacters typeCharacter

typeCharacter ->
    Llu |
    Nd |
    "\u005F"

arrayTypeName ->
    typeName "["

genericTypeName ->
    typeName "["

operatorOrPunctuator ->
    "{" | "}" | "[" | "]" | "(" | ")" | "@(" | "@{" | "$(" | ";" |
    "&&" | "||" | "&" | "|" | "," | "++" | ".." | "::" | "." | "!" |
    "*" | "/" | "%" | "+" |
    dash | dashdash | dash "and" | dash "band" | dash "bnot" |
    dash "bor" | dash "bxor" | dash "not" | dash "or" | dash "xor" |
    assignmentOperator |
    mergingRedirectionOperator |
    fileRedirectionOperator |
    comparisonOperator |
    formatOperator

assignmentOperator ->
    "=" |
    dash "=" |
    "+=" |
    "*=" |
    "/=" |
    "%="

mergingRedirectionOperator ->
    "*>&1" | "2>&1" | "3>&1" | "4>&1" | "5>&1" | "6>&1" |
    "*>&2" | "1>&2" | "3>&2" | "4>&2" | "5>&2" | "6>&2"

fileRedirectionOperator ->
    ">" | ">>" | "2>" | "2>>" | "3>" | "3>>" | "4>" | "4>>" |
    "5>" | "5>>" | "6>" | "6>>" | "*>" | "*>>" | "<"

comparisonOperator ->
    dash comparisonKeyword

comparisonKeyword ->
    "as" | "ccontains" | "ceq" | "cge" | "cgt" | "cle" | "clike" | "clt" |
    "cmatch" | "cne"| "cnotcontains" | "cnotlike" | "cnotmatch" | "contains" |
    "creplace" | "csplit" | "eq" | "ge" | "gt" | "icontains" | "ieq" | "ige" |
    "igt" | "ile" | "ilike" | "ilt" | "imatch" | "in" | "ine" | "inotcontains" |
    "inotlike" | "inotmatch" | "ireplace" | "is" | "isnot" | "isplit" |
    "join" | "le" | "like" | "lt" | "match" | "ne" | "notcontains" | "notin" |
    "notlike" | "notmatch" | "replace" | "shl" | "shr" | "split"

formatOperator ->
    dash "f"
