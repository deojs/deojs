# Powershell grammar
# From https://www.microsoft.com/en-us/download/details.aspx?id=36389

@include "../../unicode/categories/unicode_Zs.ne"
@include "../../unicode/categories/unicode_Zl.ne"
@include "../../unicode/categories/unicode_Zp.ne"
# @include "../../unicode/categories/unicode_Llu.ne"
# @include "../../unicode/categories/unicode_Lm.ne"
# @include "../../unicode/categories/unicode_Lo.ne" # Can't import this as it's too big!
# @include "../../unicode/categories/unicode_Nd.ne"

# Syntactic grammar
# Statements
scriptBlock ->
    paramBlock:? statementTerminators:? scriptBlockBody:?
    {%
        function(data) {
            return {
                type: "scriptBlock",
                data: data
            }
        }
    %}

paramBlock ->
    newLines:? attributeList:? newLines:? "param" newLines:?
        "(" parameterList:? newLines:? ")"
    {%
        function(data) {
            return {
                type: "paramBlock",
                data: data
            }
        }
    %}

parameterList ->
    scriptParameter parameterList newLines:? "," scriptParameter
    {%
        function(data) {
            return {
                type: "parameterList",
                data: data
            }
        }
    %}

scriptParameter ->
    newLines:? attributeList:? newLines:? variable scriptParameterDefault:?
    {%
        function(data) {
            return {
                type: "scriptParameter",
                data: data
            }
        }
    %}

scriptParameterDefault ->
    newLines:? "=" newLines:? expression
    {%
        function(data) {
            return {
                type: "scriptParameterDefault",
                data: data
            }
        }
    %}

scriptBlockBody ->
    namedBlockList |
    statementList
    {%
        function(data) {
            return {
                type: "scriptBlockBody",
                data: data
            }
        }
    %}

namedBlockList ->
    namedBlock:+
    {%
        function(data) {
            return {
                type: "namedBlockList",
                data: data
            }
        }
    %}

namedBlock ->
    blockName statementBlock statementTerminators:?
    {%
        function(data) {
            return {
                type: "namedBlock",
                data: data
            }
        }
    %}

blockName ->
    "dynamicparam"i |
    "begin"i |
    "process"i |
    "end"i
    {%
        function(data) {
            return {
                type: "blockName",
                data: data[0]
            }
        }
    %}

statementBlock ->
    newLines:? "{" statementList:? newLines:? "}"
    {%
        function(data) {
            return {
                type: "statementBlock",
                data: data
            }
        }
    %}

statementList ->
    statement:+
    {%
        function(data) {
            return {
                type: "statementList",
                list: data[0]
            }
        }
    %}

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
    pipeline statementTerminator:*
    {%
        function(data) {
            return {
                type: "statement",
                data: data
            }
        }
    %}

statementTerminator ->
    ";" |
    newLineCharacter
    {%
        function(data) {
            return {
                type: "statementTerminator",
                data: data[0]
            }
        }
    %}

statementTerminators ->
    statementTerminator:+
    {%
        function(data) {
            return {
                type: "statementTerminators",
                data: data
            }
        }
    %}

ifStatement ->
    "if"i newLines:? "(" newLines:? pipeline newLines:? ")" statementBlock
        elseifClauses:? elseClause:?
    {%
        function(data) {
            return {
                type: "ifStatement",
                data: data
            }
        }
    %}

elseifClauses ->
    elseifClause:+
    {%
        function(data) {
            return {
                type: "elseifClauses",
                data: data[0]
            }
        }
    %}

elseifClause ->
    newLines:? "elseif"i newLines:? "(" newLines:? pipeline newLines:? ")" statementBlock
    {%
        function(data) {
            return {
                type: "elseifClause",
                data: data
            }
        }
    %}

elseClause ->
    newLines:? "else"i statementBlock
    {%
        function(data) {
            return {
                type: "elseClause",
                data: data
            }
        }
    %}

label ->
    colon labelExpression
    {%
        function(data) {
            return {
                type: "label",
                data: data[0] + data[1] // Include the colon
            }
        }
    %}

labeledStatement ->
    switchStatement |
    foreachStatement |
    forStatement |
    whileStatement |
    doStatement
    {%
        function(data) {
            return {
                type: "labeledStatement",
                data: data[0]
            }
        }
    %}

switchStatement ->
    "switch"i newLines:? switchParameters:? switchCondition switchBody
    {%
        function(data) {
            return {
                type: "switchStatement",
                data: data
            }
        }
    %}

switchParameters ->
    switchParameter:+
    {%
        function(data) {
            return {
                type: "switchParameters",
                data: data
            }
        }
    %}

switchParameter ->
    "-regex"i |
    "-wildcard"i |
    "-exact"i |
    "-casesensitive"i |
    "-parallel"i
    {%
        function(data) {
            return {
                type: "switchParameter",
                data: data[0]
            }
        }
    %}

switchCondition ->
    "(" newLines:? pipeline newLines:? ")" |
    "-file"i newLines:? switchFilename
    {%
        function(data) {
            return {
                type: "switchCondition",
                data: data
            }
        }
    %}

switchFilename ->
    commandArgument |
    primaryExpression
    {%
        function(data) {
            return {
                type: "switchFilename",
                data: data[0]
            }
        }
    %}

switchBody ->
    newLines:? "{" newLines:? switchClauses "}"
    {%
        function(data) {
            return {
                type: "switchBody",
                data: data
            }
        }
    %}

switchClauses ->
    switchClause:+
    {%
        function(data) {
            return {
                type: "switchClauses",
                data: data
            }
        }
    %}

switchClause ->
    switchClauseCondition statementBlock statementTerminators:?
    {%
        function(data) {
            return {
                type: "switchClause",
                data: data
            }
        }
    %}

switchClauseCondition ->
    commandArgument |
    primaryExpression
    {%
        function(data) {
            return {
                type: "switchClauseCondition",
                data: data[0]
            }
        }
    %}

foreachStatement ->
    "foreach"i newLines:? foreachParameter:? newLines:?
        "(" newLines:? variable newLines:? "in"i newLines:? pipeline
        newLines:? ")" statementBlock
    {%
        function(data) {
            return {
                type: "foreachStatement",
                data: data
            }
        }
    %}

foreachParameter ->
    "-parallel"i
    {%
        function(data) {
            return {
                type: "foreachParameter",
                data: data[0]
            }
        }
    %}

forStatement ->
    "for"i newLines:? (
        "(" newLines:? forInitializer:? statementTerminator
        newLines:? forCondition:? statementTerminator
        newLines:? forIterator:? newLines:? ")" statementBlock |
        "(" newLines:? forInitializer:? statementTerminator
        newLines:? forCondition:? newLines:? ")" statementBlock |
        "(" newLines:? forInitializer:? newLines:? ")" statementBlock
    )
    {%
        function(data) {
            return {
                type: "forStatement",
                data: data
            }
        }
    %}

forInitializer->
    pipeline
    {%
        function(data) {
            return {
                type: "forInitializer",
                data: data[0]
            }
        }
    %}

forCondition ->
    pipeline
    {%
        function(data) {
            return {
                type: "forCondition",
                data: data[0]
            }
        }
    %}

forIterator ->
    pipeline
    {%
        function(data) {
            return {
                type: "forIterator",
                data: data[0]
            }
        }
    %}

whileStatement ->
    "while"i newLines:? "(" newLines:? whileCondition newLines:? ")" statementBlock
    {%
        function(data) {
            return {
                type: "whileStatement",
                data: data
            }
        }
    %}

doStatement ->
    "do"i statementBlock newLines:? "while"i newLines:? "(" whileCondition newLines:? ")" |
    "do"i statementBlock newLines:? "until"i newLines:? "(" whileCondition newLines:? ")"
    {%
        function(data) {
            return {
                type: "doStatement",
                data: data
            }
        }
    %}

whileCondition ->
    newLines:? pipeline
    {%
        function(data) {
            return {
                type: "whileCondition",
                data: data
            }
        }
    %}

functionStatement ->
    "function"i newLines:? functionName functionParameterDeclaration:? "{" scriptBlock "}" |
    "filter"i newLines:? functionName functionParameterDeclaration:? "{" scriptBlock "}" |
    "workflow"i newLines:? functionName functionParameterDeclaration:? "{" scriptBlock "}"
    {%
        function(data) {
            return {
                type: "functionStatement",
                data: data
            }
        }
    %}

functionName ->
    commandArgument
    {%
        function(data) {
            return {
                type: "functionName",
                data: data[0]
            }
        }
    %}

functionParameterDeclaration ->
    newLines:? "(" parameterList newLines:? ")"
    {%
        function(data) {
            return {
                type: "functionParameterDeclaration",
                data: data
            }
        }
    %}

flowControlStatement ->
    "break"i labelExpression:? |
    "continue"i labelExpression:? |
    "throw"i pipeline:? |
    "return"i pipeline:? |
    "exit"i pipeline:?
    {%
        function(data) {
            return {
                type: "flowControlStatement",
                data: data
            }
        }
    %}

labelExpression ->
    simpleName |
    unaryExpression
    {%
        function(data) {
            return {
                type: "labelExpression",
                data: data[0]
            }
        }
    %}

trapStatement ->
    "trap"i newLines:? typeLiteral:? newLines:? statementBlock
    {%
        function(data) {
            return {
                type: "trapStatement",
                data: data
            }
        }
    %}

tryStatement ->
    "try"i statementBlock catchClauses |
    "try"i statementBlock finallyClause |
    "try"i statementBlock catchClauses finallyClause
    {%
        function(data) {
            return {
                type: "tryStatement",
                data: data
            }
        }
    %}

catchClauses ->
    catchClause:+
    {%
        function(data) {
            return {
                type: "catchClauses",
                data: data
            }
        }
    %}

catchClause ->
    newLines:? "catch"i catchTypeList:? statementBlock
    {%
        function(data) {
            return {
                type: "catchClause",
                data: data
            }
        }
    %}

catchTypeList ->
    newLines:? typeLiteral |
    catchTypeList newLines:? "," newLines:? typeLiteral
    {%
        function(data) {
            return {
                type: "catchTypeList",
                data: data
            }
        }
    %}

finallyClause ->
    newLines:? "finally"i statementBlock
    {%
        function(data) {
            return {
                type: "finallyClause",
                data: data
            }
        }
    %}

dataStatement ->
    "data"i newLines:? dataName dataCommandsAllowed:? statementBlock
    {%
        function(data) {
            return {
                type: "dataStatement",
                data: data
            }
        }
    %}

dataName ->
    simpleName
    {%
        function(data) {
            return {
                type: "dataName",
                data: data[0]
            }
        }
    %}

dataCommandsAllowed ->
    newLines:? "-supportedcommand"i dataCommandsList
    {%
        function(data) {
            return {
                type: "dataCommandsAllowed",
                data: data
            }
        }
    %}

dataCommandsList ->
    newLines:? dataCommand |
    dataCommandsList "," newLines:? dataCommand
    {%
        function(data) {
            return {
                type: "dataCommandsList",
                data: data
            }
        }
    %}

dataCommand ->
    commandNameExpression
    {%
        function(data) {
            return {
                type: "dataCommand",
                data: data
            }
        }
    %}

inlinescriptStatement ->
    "inlinescript"i statementBlock
    {%
        function(data) {
            return {
                type: "inlineScriptStatement",
                data: data
            }
        }
    %}

parallelStatement ->
    "parallel"i statementBlock
    {%
        function(data) {
            return {
                type: "parallelStatement",
                data: data
            }
        }
    %}

sequenceStatement ->
    "sequence"i statementBlock
    {%
        function(data) {
            return {
                type: "sequenceStatement",
                data: data
            }
        }
    %}

pipeline ->
    assignmentExpression |
    expression redirections:? pipelineTail:? |
    command verbatimCommandArgument:? pipelineTail:?
    {%
        function(data) {
            return {
                type: "pipeline",
                data: data
            };
        }
    %}

assignmentExpression ->
    expression assignmentOperator statement
    {%
        function(data) {
            return {
                type: "assignmentExpression",
                data: data
            };
        }
    %}

pipelineTail ->
    "|" newLines:? command |
    "|" newLines:? command pipelineTail
    {%
        function(data) {
            return {
                type: "pipelineTail",
                data: data
            }
        }
    %}

command ->
    commandName commandElements:? |
    commandInvocationOperator commandModule:? commandNameExpression commandElements:?
    {%
        function(data) {
            return {
                type: "command",
                data: data
            }
        }
    %}

commandInvocationOperator ->
    "&" |
    "."
    {%
        function(data) {
            return {
                type: "commandInvocationOperator",
                data: data[0]
            }
        }
    %}

commandModule ->
    primaryExpression
    {%
        function(data) {
            return {
                type: "commandModule",
                data: data[0]
            }
        }
    %}

commandName ->
    genericToken |
    genericTokenWithSubexpression
    {%
        function(data) {
            return {
                type: "commandName",
                data: data[0]
            }
        }
    %}

genericTokenWithSubexpression ->
    genericTokenWithSubexpressionStart statementList:? ")" commandName # No whitespace between ) and commandName!
    {%
        function(data) {
            return {
                type: "genericTokenWithSubexpression",
                data: data
            }
        }
    %}

commandNameExpression ->
    commandName |
    primaryExpression
    {%
        function(data) {
            return {
                type: "commandNameExpression",
                data: data[0]
            }
        }
    %}

commandElements ->
    commandElement:+
    {%
        function(data) {
            return {
                type: "commandElements",
                data: data
            }
        }
    %}

commandElement ->
    commandParameter |
    commandArgument |
    redirection
    {%
        function(data) {
            return {
                type: "commandElement",
                data: data[0]
            }
        }
    %}

commandArgument ->
    commandNameExpression
    {%
        function(data) {
            return {
                type: "commandArgument",
                data: data[0]
            }
        }
    %}

verbatimCommandArgument ->
    "--%" verbatimCommandArgumentChars
    {%
        function(data) {
            return {
                type: "verbatimCommandArgument",
                data: data
            }
        }
    %}

redirections ->
    redirection:+
    {%
        function(data) {
            return {
                type: "redirections",
                data: data
            }
        }
    %}

redirection ->
    mergingRedirectionOperator |
    fileRedirectionOperator redirectedFileName
    {%
        function(data) {
            return {
                type: "redirection",
                data: data
            }
        }
    %}

redirectedFileName ->
    commandArgument |
    primaryExpression
    {%
        function(data) {
            return {
                type: "redirectedFileName",
                data: data[0]
            }
        }
    %}

# Expressions
expression ->
    logicalExpression
    {%
        function(data) {
            return {
                type: "expression",
                data: data[0]
            }
        }
    %}

logicalExpression ->
    bitwiseExpression |
    logicalExpression "-and"i newLines:? bitwiseExpression |
    logicalExpression "-or"i newLines:? bitwiseExpression |
    logicalExpression "-xor"i newLines:? bitwiseExpression
    {%
        function(data) {
            return {
                type: "logicalExpression",
                data: data
            }
        }
    %}

bitwiseExpression ->
    comparisonExpression |
    bitwiseExpression "-band" newLines:? comparisonExpression |
    bitwiseExpression "-bor" newLines:? comparisonExpression |
    bitwiseExpression "-bxor" newLines:? comparisonExpression
    {%
        function(data) {
            return {
                type: "bitwiseExpression",
                data: data
            }
        }
    %}

comparisonExpression ->
    additiveExpression |
    comparisonExpression comparisonOperator newLines:? additiveExpression
    {%
        function(data) {
            return {
                type: "comparisonExpression",
                data: data
            }
        }
    %}

additiveExpression ->
    multiplicativeExpression |
    additiveExpression "+" newLines:? multiplicativeExpression |
    additiveExpression dash newLines:? multiplicativeExpression
    {%
        function(data) {
            return {
                type: "additiveExpression",
                data: data
            }
        }
    %}

multiplicativeExpression ->
    formatExpression |
    multiplicativeExpression "*" newLines:? formatExpression |
    multiplicativeExpression "/" newLines:? formatExpression |
    multiplicativeExpression "%" newLines:? formatExpression
    {%
        function(data) {
            return {
                type: "multiplicativeExpression",
                data: data
            }
        }
    %}

formatExpression ->
    rangeExpression |
    formatExpression formatOperator newLines:? rangeExpression
    {%
        function(data) {
            return {
                type: "formatExpression",
                data: data
            }
        }
    %}

rangeExpression ->
    arrayLiteralExpression |
    rangeExpression ".." newLines:? arrayLiteralExpression
    {%
        function(data) {
            return {
                type: "rangeExpression",
                data: data
            }
        }
    %}

arrayLiteralExpression ->
    unaryExpression |
    unaryExpression "," newLines:? arrayLiteralExpression
    {%
        function(data) {
            return {
                type: "arrayLiteralExpression",
                data: data
            }
        }
    %}

unaryExpression ->
    primaryExpression |
    expressionWithUnaryOperator
    {%
        function(data) {
            return {
                type: "unaryExpression",
                data: data[0]
            }
        }
    %}

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
    {%
        function(data) {
            return {
                type: "expressionWithUnaryOperator",
                data: data
            }
        }
    %}

preIncrementExpression ->
    "++" newLines:? unaryExpression
    {%
        function(data) {
            return {
                type: "preIncrementExpression",
                data: data
            }
        }
    %}

preDecrementExpression ->
    dashdash newLines:? unaryExpression
    {%
        function(data) {
            return {
                type: "preDecrementExpression",
                data: data
            }
        }
    %}

castExpression ->
    typeLiteral unaryExpression
    {%
        function(data) {
            return {
                type: "castExpression",
                data: data
            }
        }
    %}

attributedExpression ->
    typeLiteral variable
    {%
        function(data) {
            return {
                type: "attributedExpression",
                data: data
            }
        }
    %}

primaryExpression ->
    value |
    memberAccess |
    elementAccess |
    invocationExpression |
    postIncrementExpression |
    postDecrementExpression
    {%
        function(data) {
            return {
                type: "primaryExpression",
                data: data[0]
            }
        }
    %}

value ->
    parenthesizedExpression |
    subExpression |
    arrayExpression |
    scriptBlockExpression |
    hashLiteralExpression |
    literal |
    typeLiteral |
    variable
    {%
        function(data) {
            return {
                type: "value",
                data: data[0]
            }
        }
    %}

parenthesizedExpression ->
    "(" newLines:? pipeline newLines:? ")"
    {%
        function(data) {
            return {
                type: "parenthesizedExpression",
                data: data
            }
        }
    %}

subExpression ->
    "$(" newLines:? statementList:? newLines:? ")"
    {%
        function(data) {
            return {
                type: "subExpression",
                data: data
            }
        }
    %}

arrayExpression ->
    "@(" newLines:? statementList:? newLines:? ")"
    {%
        function(data) {
            return {
                type: "arrayExpression",
                data: data
            }
        }
    %}

scriptBlockExpression ->
    "{" newLines:? scriptBlock newLines:? "}"
    {%
        function(data) {
            return {
                type: "scriptBlockExpression",
                data: data
            }
        }
    %}

hashLiteralExpression ->
    "@{" newLines:? hashLiteralBody:? newLines:? "}"
    {%
        function(data) {
            return {
                type: "hashLiteralExpression",
                data: data
            }
        }
    %}

hashLiteralBody ->
    hashEntry |
    hashLiteralBody statementTerminators hashEntry
    {%
        function(data) {
            return {
                type: "hashLiteralBody",
                data: data
            }
        }
    %}

hashEntry ->
    keyExpression "=" newLines:? statement
    {%
        function(data) {
            return {
                type: "hashEntry",
                data: data
            }
        }
    %}

keyExpression ->
    simpleName |
    unaryExpression
    {%
        function(data) {
            return {
                type: "keyExpression",
                data: data[0]
            }
        }
    %}

postIncrementExpression ->
    primaryExpression "++"
    {%
        function(data) {
            return {
                type: "postIncrementExpression",
                data: data
            }
        }
    %}

postDecrementExpression ->
    primaryExpression dashdash
    {%
        function(data) {
            return {
                type: "postDecrementExpression",
                data: data
            }
        }
    %}

memberAccess -> # No whitespace after primaryExpression
    primaryExpression "." memberName |
    primaryExpression "::" memberName
    {%
        function(data) {
            return {
                type: "memberAccess",
                data: data
            }
        }
    %}

elementAccess -> # No whitespace between primaryExpression and "["
    primaryExpression "[" newLines:? expression newLines:? "]"
    {%
        function(data) {
            return {
                type: "elementAccess",
                data: data
            }
        }
    %}

invocationExpression -> # No whitespace after primaryExpression
    primaryExpression "." memberName argumentList |
    primaryExpression "::" memberName argumentList
    {%
        function(data) {
            return {
                type: "invocationExpression",
                data: data
            }
        }
    %}

argumentList ->
    "(" argumentExpressionList:? newLines:? ")"
    {%
        function(data) {
            return {
                type: "argumentList",
                data: data
            }
        }
    %}

argumentExpressionList ->
    argumentExpression |
    argumentExpression newLines:? "," argumentExpressionList
    {%
        function(data) {
            return {
                type: "argumentExpressionList",
                data: data
            }
        }
    %}

argumentExpression ->
    newLines:? logicalArgumentExpression
    {%
        function(data) {
            return {
                type: "argumentExpression",
                data: data
            }
        }
    %}

logicalArgumentExpression ->
    bitwiseArgumentExpression |
    logicalArgumentExpression "-and"i newLines:? bitwiseArgumentExpression |
    logicalArgumentExpression "-or"i newLines:? bitwiseArgumentExpression |
    logicalArgumentExpression "-xor"i newLines:? bitwiseArgumentExpression
    {%
        function(data) {
            return {
                type: "logicalArgumentExpression",
                data: data
            }
        }
    %}

bitwiseArgumentExpression ->
    comparisonArgumentExpression |
    bitwiseArgumentExpression "-band"i newLines:? comparisonArgumentExpression |
    bitwiseArgumentExpression "-bor"i newLines:? comparisonArgumentExpression |
    bitwiseArgumentExpression "-bxor"i newLines:? comparisonArgumentExpression
    {%
        function(data) {
            return {
                type: "bitwiseArgumentExpression",
                data: data
            }
        }
    %}

comparisonArgumentExpression ->
    additiveArgumentExpression |
    comparisonArgumentExpression comparisonOperator newLines:? additiveArgumentExpression
    {%
        function(data) {
            return {
                type: "comparisonArgumentExpression",
                data: data
            }
        }
    %}

additiveArgumentExpression ->
    multiplicativeArgumentExpression |
    additiveArgumentExpression "+" newLines:? multiplicativeArgumentExpression |
    additiveArgumentExpression dash newLines:? multiplicativeArgumentExpression
    {%
        function(data) {
            return {
                type: "additiveArgumentExpression",
                data: data
            }
        }
    %}

multiplicativeArgumentExpression ->
    formatArgumentExpression |
    multiplicativeArgumentExpression "*" newLines:? formatArgumentExpression |
    multiplicativeArgumentExpression "/" newLines:? formatArgumentExpression |
    multiplicativeArgumentExpression "%" newLines:? formatArgumentExpression
    {%
        function(data) {
            return {
                type: "multiplicativeArgumentExpression",
                data: data
            }
        }
    %}

formatArgumentExpression ->
    rangeArgumentExpression |
    formatArgumentExpression formatOperator newLines:? rangeArgumentExpression
    {%
        function(data) {
            return {
                type: "formatArgumentExpression",
                data: data
            }
        }
    %}

rangeArgumentExpression ->
    unaryExpression |
    rangeExpression ".." newLines:? unaryExpression
    {%
        function(data) {
            return {
                type: "rangeArgumentExpression",
                data: data
            }
        }
    %}

memberName ->
    simpleName |
    stringLiteral |
    stringLiteralWithSubexpression |
    expressionWithUnaryOperator |
    value
    {%
        function(data) {
            return {
                type: "memberName",
                data: data[0]
            }
        }
    %}

stringLiteralWithSubexpression ->
    expandableStringLiteralWithSubexpression
    {%
        function(data) {
            return {
                type: "stringLiteralWithSubexpression",
                data: data[0]
            }
        }
    %}

expandableStringLiteralWithSubexpression ->
    expandableStringWithSubexpressionStart statementList:? ")" expandableStringWithSubexpressionChars expandableStringWithSubexpressionEnd |
    expandableHereStringWithSubexpressionStart statementList:? ")" expandableHereStringWithSubexpressionChars expandableHereStringWithSubexpressionEnd
    {%
        function(data) {
            return {
                type: "expandableStringLiteralWithSubexpression",
                data: data
            }
        }
    %}

expandableStringWithSubexpressionChars ->
    expandableStringWithSubexpressionPart |
    expandableStringWithSubexpressionChars expandableStringWithSubexpressionPart
    {%
        function(data) {
            return {
                type: "expandableStringWithSubexpressionChars",
                data: data
            }
        }
    %}

expandableStringWithSubexpressionPart ->
    subExpression |
    expandableStringPart
    {%
        function(data) {
            return {
                type: "expandableStringWithSubexpressionPart",
                data: data[0]
            }
        }
    %}

expandableHereStringWithSubexpressionChars ->
    expandableHereStringWithSubexpressionPart |
    expandableHereStringWithSubexpressionChars expandableHereStringWithSubexpressionPart
    {%
        function(data) {
            return {
                type: "expandableHereStringWithSubExpressionPart",
                data: data
            }
        }
    %}

expandableHereStringWithSubexpressionPart ->
    subExpression |
    expandableHereStringPart
    {%
        function(data) {
            return {
                type: "expandableHereStringWithSubexpressionPart",
                data: data[0]
            }
        }
    %}

typeLiteral ->
    "[" typeSpec "]"
    {%
        function(data) {
            return {
                type: "typeLiteral",
                data: data
            }
        }
    %}

typeSpec ->
    arrayTypeName newLines:? dimension:? "]" |
    genericTypeName newLines:? genericTypeArguments "]" |
    typeName
    {%
        function(data) {
            return {
                type: "typeSpec",
                data: data
            }
        }
    %}

dimension ->
    "," |
    dimension ","
    {%
        function(data) {
            return {
                type: "dimension",
                data: data
            }
        }
    %}

genericTypeArguments ->
    typeSpec newLines:? |
    genericTypeArguments "," newLines:? typeSpec
    {%
        function(data) {
            return {
                type: "genericTypeArguments",
                data: data
            }
        }
    %}

# Attributes
attributeList ->
    attribute |
    attributeList newLines:? attribute
    {%
        function(data) {
            return {
                type: "attributeList",
                data: data
            }
        }
    %}

attribute ->
    "[" newLines:? attributeName "(" attributeArguments newLines:? ")" newLines:? "]" |
    typeLiteral
    {%
        function(data) {
            return {
                type: "attribute",
                data: data
            }
        }
    %}

attributeName ->
    typeSpec
    {%
        function(data) {
            return {
                type: "attributeName",
                data: data[0]
            }
        }
    %}

attributeArguments ->
    attributeArgument |
    attributeArgument newLines:? "," attributeArguments
    {%
        function(data) {
            return {
                type: "attributeArguments",
                data: data
            }
        }
    %}

attributeArgument ->
    newLines:? expression |
    newLines:? simpleName |
    newLines:? simpleName "=" newLines:? expression
    {%
        function(data) {
            return {
                type: "attributeArgument",
                data: data
            }
        }
    %}

# Lexical grammar
input ->
    inputElements:? signatureBlock:?
    {%
        function(data) {
            return {
                type: "input",
                data: data
            }
        }
    %}

inputElements ->
    inputElement:+
    {%
        function(data) {
            return {
                type: "inputElements",
                data: data
            }
        }
    %}

inputElement ->
    whitespace |
    comment |
    token
    {%
        function(data) {
            return {
                type: "inputElement",
                data: data
            }
        }
    %}

signatureBlock ->
    signatureBegin signature signatureEnd
    {%
        function(data) {
            return {
                type: "signatureBlock",
                data: data
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
    singleLineComment |
    singleLineComments newLineCharacter singleLineComment
    {%
        function(data) {
            return {
                type: "singleLineComments",
                data: data
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
    carriageReturnCharacter |
    lineFeedCharacter |
    carriageReturnCharacter lineFeedCharacter
    {%
        function(data) {
            return {
                type: "newLineCharacter",
                data: data[0]
            }
        }
    %}

carriageReturnCharacter ->
    [\r]
    {%
        function(data) {
            return {
                type: "carriageReturnCharacter",
                data: data[0]
            }
        }
    %}

lineFeedCharacter ->
    [\n]
    {%
        function(data) {
            return {
                type: "lineFeedCharacter",
                data: data[0]
            }
        }
    %}

newLines ->
    newLineCharacter:+
    {%
        function(data) {
            return {
                type: "newLines",
                data: data
            }
        }
    %}

# Comments
comment ->
    singleLineComment |
    requiresComment |
    delimitedComment
    {%
        function(data) {
            return {
                type: "comment",
                data: data[0]
            }
        }
    %}

singleLineComment ->
    "#" inputCharacters:?
    {%
        function(data) {
            let out = ""
            for (let i = 0; i < data.length; i++) {
                out += data[i]
            }
            return {
                type: "singleLineComment",
                data: out
            }
        }
    %}

inputCharacters ->
    inputCharacter:+
    {%
        function(data) {
            let out = ""
            for (let i = 0; i < data.length; i++) {
                out += data[i]
            }
            return {
                type: "inputCharacters",
                data: out
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
    "#requires" whitespace commandArgument # Docs says commandArguments but might be a typo?
    {%
        function(data) {
            return {
                type: "requiresComment",
                data: data
            }
        }
    %}

dash ->
    "\u002D" |
    "\u2013" |
    "\u2014" |
    "\u2015"
    {%
        function(data) {
            return {
                type: "dash",
                data: data[0]
            }
        }
    %}

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
            let out = ""
            for (let i = 0; i < data.length; i++) {
                out += data[i]
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
            let out = ""
            for (let i = 0; i < data.length; i++) {
                out += data[i]
            }
            return {
                type: "delimitedCommentText",
                data: out
            }
        }
    %}

delimitedCommentSection ->
    ">" |
    hashes:? notGreaterThanOrHash
    {%
        function(data) {
            let out = ""
            for (let i = 0; i < data.length; i++) {
                out += data[i]
            }
            return {
                type: "delimitedCommentSection",
                data: out
            }
        }
    %}

hashes ->
    "#":+
    {%
        function(data) {
            let out = ""
            for (let i = 0; i < data.length; i++) {
                out += data[i]
            }
            return {
                type: "hashes",
                data: out
            }
        }
    %}

notGreaterThanOrHash ->
    [^>#]
    {%
        function(data) {
            return {
                type: "notGreaterThanOrHash",
                data: data[0]
            }
        }
    %}

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
    {%
        function(data) {
            let out = ""
            for (let i = 0; i < data.length; i++) {
                out += data[i]
            }
            return {
                type: "whitespace",
                data: out
            }
        }
    %}

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
    {%
        function(data) {
            return {
                type: "token",
                data: data[0]
            }
        }
    %}

keyword ->
    "begin" | "break" | "catch" | "class" | "continue" | "data" |
    "define" | "do" | "dynamicparam" | "else" | "elseif" | "end" |
    "exit" | "filter" | "finally" | "for" | "foreach" | "from" |
    "function" | "if" | "in" | "inlinescript" | "parallel" | "param" |
    "process" | "return" | "switch" | "throw" | "trap" | "try" |
    "until" | "using" | "var" | "while" | "workflow"
    {%
        function(data) {
            return {
                type: "keyword",
                data: data[0]
            }
        }
    %}

variable ->
    "$$" |
    "$?" |
    "$^" |
    "$" variableScope:? variableCharacters |
    "@" variableScope:? variableCharacters |
    bracedVariable
    {%
        function(data) {
            return {
                type: "variable",
                data: data
            }
        }
    %}

bracedVariable ->
    "${" variableScope:? bracedVariableCharacters "}"
    {%
        function(data) {
            return {
                type: "bracedVariable",
                data: data
            }
        }
    %}

variableScope ->
    "global:" |
    "local:" |
    "private:" |
    "script:" |
    "using:" |
    "workflow:" |
    variableNamespace
    {%
        function(data) {
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
            let out = ""
            for (let i = 0; i < data.length; i++) {
                out += data[i]
            }
            return {
                type: "variableCharacters",
                data: out
            }
        }
    %}

variableCharacter ->
    # This should include the unicode category 'Lo', however this has >120,000 characters so is too big
    Llu |
    Lm |
    Nd |
    "\u005F" |
    "?"
    {%
        function(data) {
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
            let out = ""
            for (let i = 0; i < data.length; i++) {
                out += data[i]
            }
            return {
                type: "bracedVariableCharacters",
                data: out
            }
        }
    %}

bracedVariableCharacter ->
    [^\u007D\u0060] |
    escapedCharacter
    {%
        function(data) {
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
            return {
                type: "escapedCharacter",
                data: data[0] + data[1]
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
                data: data[0].data
            }
        }
    %}

genericTokenParts ->
    genericTokenPart:+
    {%
        function(data) {
            let out = ""
            for (let i = 0; i < data[0].length; i++) {
                out += data[0][i].data;
            }

            return {
                type: "genericTokenParts",
                data: out
            }
        }
    %}

genericTokenPart ->
    genericTokenCharacter:+
    {%
        function(data) {
            let out = ""
            for (let i = 0; i < data[0].length; i++) {
                out += data[0][i]
            }
            return {
                type: "genericTokenPart",
                data: out
            }
        }
    %}

genericTokenCharacter ->
    [^{}();,|&$\u0060'"\r\n\s] |
    escapedCharacter
    {%
        function(data) {
            if (data[0].hasOwnProperty("type") && data[0].type == "escapedCharacter") {
                return data[0].data
            }
            return {
                type: "genericTokenCharacter",
                data: data[0]
            }
        }
    %}

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
    parameterChar:+
    # parameterChar |
    # parameterChars parameterChar

parameterChar ->
    [^{}();,|&.[\u003A\r\n\s]

colon ->
    "\u003A"

verbatimCommandArgumentChars ->
    verbatimCommandArgumentPart:+
    # verbatimCommandArgumentPart |
    # verbatimCommandArgumentChars verbatimCommandArgumentPart

verbatimCommandArgumentPart ->
    verbatimCommandString |
    "&" nonAmpersandCharacter |
    [^|\r\n]

nonAmpersandCharacter ->
    [^&]

verbatimCommandString ->
    doubleQuoteCharacter nonDoubleQuoteCharacters doubleQuoteCharacter

nonDoubleQuoteCharacters ->
    nonDoubleQuoteCharacter:+
    # nonDoubleQuoteCharacter |
    # nonDoubleQuoteCharacters nonDoubleQuoteCharacter

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
    decimalDigit:+
    # decimalDigit |
    # decimalDigit decimalDigits

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
    expandableStringPart:+
    # expandableStringPart |
    # expandableStringCharacters expandableStringPart

expandableStringPart ->
    [^$\u0022\u201C\u201D\u201E\u0060] |
    bracedVariable |
    "$" [^({\u0022\u201C\u201D\u201E\u0060] |
    "$" escapedCharacter |
    escapedCharacter |
    doubleQuoteCharacter doubleQuoteCharacter

dollars ->
    "$":+
    # "$" |
    # dollars "$"

expandableHereStringLiteral ->
    "@" doubleQuoteCharacter whitespace:? newLineCharacter expandableHereStringCharacters:? newLineCharacter doubleQuoteCharacter "@"

expandableHereStringCharacters ->
    expandableHereStringPart:+
    # expandableHereStringPart |
    # expandableHereStringCharacters expandableHereStringPart

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
    verbatimStringPart:+
    # verbatimStringPart |
    # verbatimStringCharacters verbatimStringPart

verbatimStringPart ->
    nonSingleQuoteCharacter |
    singleQuoteCharacter singleQuoteCharacter

verbatimHereStringLiteral ->
    "@" singleQuoteCharacter whitespace:? newLineCharacter verbatimHereStringCharacters:? newLineCharacter singleQuoteCharacter "@"

verbatimHereStringCharacters ->
    verbatimHereStringPart:+
    # verbatimHereStringPart |
    # verbatimHereStringCharacters verbatimHereStringPart

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
    simpleNameChar:+
    # simpleNameChar |
    # simpleNameChars simpleNameChar

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
    typeCharacter:+
    # typeCharacter |
    # typeCharacters typeCharacter

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

# Unicode groups
# This isn't entirely what PowerShell will accept, but the full unicode group is too big
Llu ->
    [A-Za-z]

Lm ->
    [^$0-9(@\r\n]

Nd ->
    [0-9]
