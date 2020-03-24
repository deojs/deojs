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
# Statements
scriptBlock ->
    paramBlock:? _ statementTerminators:? _ scriptBlockBody:?
    {%
        function(data) {
            const out = [];

            return {
                type: "scriptBlock",
                data: data
            }
        }
    %}

paramBlock ->
    newLines:? _ attributeList:? _ newLines:? _ "param" _ newLines:?
        _ "(" _ parameterList:? _ newLines:? _ ")"
    {%
        function(data) {
            return {
                type: "paramBlock",
                data: data
            }
        }
    %}

parameterList ->
    scriptParameter __ parameterList _ newLines:? _ "," _ scriptParameter
    {%
        function(data) {
            return {
                type: "parameterList",
                data: data
            }
        }
    %}

scriptParameter ->
    newLines:? _ attributeList:? _ newLines:? _ variable __ scriptParameterDefault:?
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
                data: data[0]
            }
        }
    %}

namedBlockList ->
    namedBlock |
    namedBlockList namedBlock
    {%
        function(data) {
            return {
                type: "namedBlockList",
                data: data
            }
        }
    %}

namedBlock ->
    blockName _ statementBlock _ statementTerminators:?
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
    newLines:? _ "{" _ statementList:? _ newLines:? _ "}"
    {%
        function(data) {
            return {
                type: "statementBlock",
                data: data
            }
        }
    %}

statementList ->
    statement |
    statementList _:? newLines:? _ statement
    {%
        function(data) {
            return {
                type: "statementList",
                data: data[0]
            }
        }
    %}

statement ->
    comment (statementTerminator | newLineCharacter) |
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
    pipeline _ statementTerminators
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
    statementTerminator |
    statementTerminators _ statementTerminator
    {%
        function(data) {
            return {
                type: "statementTerminators",
                data: data
            }
        }
    %}

ifStatement ->
    "if"i _ newLines:? _ "(" _ newLines:? _ pipeline _ newLines:? _ ")" _ statementBlock _
        elseifClauses:? _ elseClause:?
    {%
        function(data) {
            return {
                type: "ifStatement",
                data: data
            }
        }
    %}

elseifClauses ->
    elseifClause |
    elseifClauses _ elseifClause
    {%
        function(data) {
            return {
                type: "elseifClauses",
                data: data[0]
            }
        }
    %}

elseifClause ->
    newLines:? _ "elseif"i _ newLines:? _ "(" _ newLines:? _ pipeline _ newLines:? _ ")" _ statementBlock
    {%
        function(data) {
            return {
                type: "elseifClause",
                data: data
            }
        }
    %}

elseClause ->
    newLines:? _ "else"i _ statementBlock
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
    "switch"i _ newLines:? _ switchParameters:? _ switchCondition _ switchBody
    {%
        function(data) {
            return {
                type: "switchStatement",
                data: data
            }
        }
    %}

switchParameters ->
    switchParameter |
    switchParameters _ switchParameter
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
    "(" _ newLines:? _ pipeline _ newLines:? _ ")" |
    "-file"i _ newLines:? _ switchFilename
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
    newLines:? _ "{" _ newLines:? _ switchClauses _ "}"
    {%
        function(data) {
            return {
                type: "switchBody",
                data: data
            }
        }
    %}

switchClauses ->
    switchClause |
    switchClauses _ switchClause
    {%
        function(data) {
            return {
                type: "switchClauses",
                data: data
            }
        }
    %}

switchClause ->
    switchClauseCondition _ statementBlock _ statementTerminators:?
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
    "foreach"i _ newLines:? _ foreachParameter:? _ newLines:? _
        "(" _ newLines:? _ variable _ newLines:? _ "in"i _ newLines:? _ pipeline _
        newLines:? _ ")" _ statementBlock
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
    "for"i _ newLines:? _ (
        "(" _ newLines:? _ forInitializer:? _ statementTerminator _
        newLines:? _ forCondition:? _ statementTerminator _
        newLines:? _ forIterator:? _ newLines:? _ ")" _ statementBlock |
        "(" _ newLines:? _ forInitializer:? _ statementTerminator _
        newLines:? _ forCondition:? _ newLines:? _ ")" _ statementBlock |
        "(" _ newLines:? _ forInitializer:? _ newLines:? _ ")" _ statementBlock
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
    "while"i _ newLines:? _ "(" newLines:? _ whileCondition _ newLines:? _ ")" _ statementBlock
    {%
        function(data) {
            return {
                type: "whileStatement",
                data: data
            }
        }
    %}

doStatement ->
    "do"i _ statementBlock _ newLines:? _ "while"i _ newLines:? _ "(" _ whileCondition _ newLines:? _ ")" |
    "do"i _ statementBlock _ newLines:? _ "until"i _ newLines:? _ "(" _ whileCondition _ newLines:? _ ")"
    {%
        function(data) {
            return {
                type: "doStatement",
                data: data
            }
        }
    %}

whileCondition ->
    newLines:? _ pipeline
    {%
        function(data) {
            return {
                type: "whileCondition",
                data: data
            }
        }
    %}

functionStatement ->
    "function"i _ newLines:? _ functionName _ functionParameterDeclaration:? _ "{" _ scriptBlock _ "}" |
    "filter"i _ newLines:? _ functionName _ functionParameterDeclaration:? _ "{" _ scriptBlock _ "}" |
    "workflow"i _ newLines:? _ functionName _ functionParameterDeclaration:? _ "{" _ scriptBlock _ "}"
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
    newLines:? _ "(" _ parameterList _ newLines:? _ ")"
    {%
        function(data) {
            return {
                type: "functionParameterDeclaration",
                data: data
            }
        }
    %}

flowControlStatement ->
    "break"i __ labelExpression:? |
    "continue"i __ labelExpression:? |
    "throw"i __ pipeline:? |
    "return"i __ pipeline:? |
    "exit"i __ pipeline:?
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
    "trap"i _ newLines:? _ typeLiteral:? _ newLines:? _ statementBlock
    {%
        function(data) {
            return {
                type: "trapStatement",
                data: data
            }
        }
    %}

tryStatement ->
    "try"i _ statementBlock _ catchClauses |
    "try"i _ statementBlock _ finallyClause |
    "try"i _ statementBlock _ catchClauses _ finallyClause
    {%
        function(data) {
            return {
                type: "tryStatement",
                data: data
            }
        }
    %}

catchClauses ->
    catchClause |
    catchClauses _ catchClause
    {%
        function(data) {
            return {
                type: "catchClauses",
                data: data
            }
        }
    %}

catchClause ->
    newLines:? _ "catch"i _ catchTypeList:? _ statementBlock
    {%
        function(data) {
            return {
                type: "catchClause",
                data: data
            }
        }
    %}

catchTypeList ->
    newLines:? _ typeLiteral |
    catchTypeList _ newLines:? _ "," _ newLines:? _ typeLiteral
    {%
        function(data) {
            return {
                type: "catchTypeList",
                data: data
            }
        }
    %}

finallyClause ->
    newLines:? _ "finally"i _ statementBlock
    {%
        function(data) {
            return {
                type: "finallyClause",
                data: data
            }
        }
    %}

dataStatement ->
    "data"i _ newLines:? _ dataName _ dataCommandsAllowed:? _ statementBlock
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
    newLines:? _ "-supportedcommand"i _ dataCommandsList
    {%
        function(data) {
            return {
                type: "dataCommandsAllowed",
                data: data
            }
        }
    %}

dataCommandsList ->
    newLines:? _ dataCommand |
    dataCommandsList _ "," _ newLines:? _ dataCommand
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
                data: data[0]
            }
        }
    %}

inlinescriptStatement ->
    "inlinescript"i __ statementBlock
    {%
        function(data) {
            return {
                type: "inlineScriptStatement",
                data: data
            }
        }
    %}

parallelStatement ->
    "parallel"i __ statementBlock
    {%
        function(data) {
            return {
                type: "parallelStatement",
                data: data
            }
        }
    %}

sequenceStatement ->
    "sequence"i __ statementBlock
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
    expression _ redirections:? _ pipelineTail:? |
    command _ verbatimCommandArgument:? _ pipelineTail:?
    {%
        function(data) {
            return {
                type: "pipeline",
                data: data
            };
        }
    %}

assignmentExpression ->
    expression _ assignmentOperator _ statement
    {%
        function(data) {
            return {
                type: "assignmentExpression",
                data: data
            };
        }
    %}

pipelineTail ->
    "|" _ newLines:? _ command |
    "|" _ newLines:? _ command _ pipelineTail
    {%
        function(data) {
            return {
                type: "pipelineTail",
                data: data
            }
        }
    %}

command ->
    commandName (__ commandElements):? |
    commandInvocationOperator _ commandModule:? _ commandNameExpression _ commandElements:?
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
    genericTokenWithSubexpressionStart _ statementList:? _ ")" commandName # No whitespace between ) and commandName!
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
    commandElement |
    commandElements __ commandElement
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
    redirection |
    redirections _ redirection
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
    fileRedirectionOperator _ redirectedFileName
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
    logicalExpression _ "-and"i _ newLines:? _ bitwiseExpression |
    logicalExpression _ "-or"i _ newLines:? _ bitwiseExpression |
    logicalExpression _ "-xor"i _ newLines:? _ bitwiseExpression
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
    bitwiseExpression _ "-band" _ newLines:? _ comparisonExpression |
    bitwiseExpression _ "-bor" _ newLines:? _ comparisonExpression |
    bitwiseExpression _ "-bxor" _ newLines:? _ comparisonExpression
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
    comparisonExpression _ comparisonOperator _ newLines:? _ additiveExpression
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
    additiveExpression _ "+" _ newLines:? multiplicativeExpression |
    additiveExpression _ dash _ newLines:? multiplicativeExpression
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
    multiplicativeExpression _ "*" _ newLines:? _ formatExpression |
    multiplicativeExpression _ "/" _ newLines:? _ formatExpression |
    multiplicativeExpression _ "%" _ newLines:? _ formatExpression
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
    formatExpression _ formatOperator _ newLines:? _ rangeExpression
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
    rangeExpression _ ".." _ newLines:? _ arrayLiteralExpression
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
    unaryExpression _ "," _ newLines:? _ arrayLiteralExpression
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
    "," _ newLines:? _ unaryExpression |
    "-not"i _ newLines:? _ unaryExpression |
    "!" _ newLines:? _ unaryExpression |
    "-bnot"i _ newLines:? _ unaryExpression |
    "+" _ newLines:? _ unaryExpression |
    dash _ newLines:? _ unaryExpression |
    preIncrementExpression |
    preDecrementExpression |
    castExpression |
    "-split"i _ newLines:? _ unaryExpression |
    "-join"i _ newLines:? _ unaryExpression
    {%
        function(data) {
            return {
                type: "expressionWithUnaryOperator",
                data: data
            }
        }
    %}

preIncrementExpression ->
    "++" _ newLines:? _ unaryExpression
    {%
        function(data) {
            return {
                type: "preIncrementExpression",
                data: data
            }
        }
    %}

preDecrementExpression ->
    dashdash _ newLines:? _ unaryExpression
    {%
        function(data) {
            return {
                type: "preDecrementExpression",
                data: data
            }
        }
    %}

castExpression ->
    typeLiteral _ unaryExpression
    {%
        function(data) {
            return {
                type: "castExpression",
                data: data
            }
        }
    %}

attributedExpression ->
    typeLiteral _ variable
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
    "(" _ newLines:? _ pipeline _ newLines:? _ ")"
    {%
        function(data) {
            return {
                type: "parenthesizedExpression",
                data: data
            }
        }
    %}

subExpression ->
    "$(" _ newLines:? _ statementList:? _ newLines:? _ ")"
    {%
        function(data) {
            return {
                type: "subExpression",
                data: data
            }
        }
    %}

arrayExpression ->
    "@(" _ newLines:? _ statementList:? _ newLines:? _ ")"
    {%
        function(data) {
            return {
                type: "arrayExpression",
                data: data
            }
        }
    %}

scriptBlockExpression ->
    "{" _ newLines:? _ scriptBlock _ newLines:? _ "}"
    {%
        function(data) {
            return {
                type: "scriptBlockExpression",
                data: data
            }
        }
    %}

hashLiteralExpression ->
    "@{" _ newLines:? _ hashLiteralBody:? _ newLines:? _ "}"
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
    hashLiteralBody _ statementTerminators _ hashEntry
    {%
        function(data) {
            return {
                type: "hashLiteralBody",
                data: data
            }
        }
    %}

hashEntry ->
    keyExpression _ "=" _ newLines:? _ statement
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
    primaryExpression _ "++"
    {%
        function(data) {
            return {
                type: "postIncrementExpression",
                data: data
            }
        }
    %}

postDecrementExpression ->
    primaryExpression _ dashdash
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
    primaryExpression "[" _ newLines:? _ expression _ newLines:? _ "]"
    {%
        function(data) {
            return {
                type: "elementAccess",
                data: data
            }
        }
    %}

invocationExpression -> # No whitespace after primaryExpression
    primaryExpression "." memberName _ argumentList |
    primaryExpression "::" memberName _ argumentList
    {%
        function(data) {
            return {
                type: "invocationExpression",
                data: data
            }
        }
    %}

argumentList ->
    "(" _ argumentExpressionList:? _ newLines:? _ ")"
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
    argumentExpression _ newLines:? _ "," _ argumentExpressionList
    {%
        function(data) {
            return {
                type: "argumentExpressionList",
                data: data
            }
        }
    %}

argumentExpression ->
    newLines:? _ logicalArgumentExpression
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
    logicalArgumentExpression _ "-and"i _ newLines:? _ bitwiseArgumentExpression |
    logicalArgumentExpression _ "-or"i _ newLines:? _ bitwiseArgumentExpression |
    logicalArgumentExpression _ "-xor"i _ newLines:? _ bitwiseArgumentExpression
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
    bitwiseArgumentExpression _ "-band"i _ newLines:? _ comparisonArgumentExpression |
    bitwiseArgumentExpression _ "-bor"i _ newLines:? _ comparisonArgumentExpression |
    bitwiseArgumentExpression _ "-bxor"i _ newLines:? _ comparisonArgumentExpression
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
    comparisonArgumentExpression _ comparisonOperator _ newLines:? _ additiveArgumentExpression
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
    additiveArgumentExpression _ "+" _ newLines:? _ multiplicativeArgumentExpression |
    additiveArgumentExpression _ dash _ newLines:? _ multiplicativeArgumentExpression
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
    multiplicativeArgumentExpression _ "*" _ newLines:? _ formatArgumentExpression |
    multiplicativeArgumentExpression _ "/" _ newLines:? _ formatArgumentExpression |
    multiplicativeArgumentExpression _ "%" _ newLines:? _ formatArgumentExpression
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
    formatArgumentExpression _ formatOperator _ newLines:? _ rangeArgumentExpression
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
    rangeExpression _ ".." _ newLines:? _ unaryExpression
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
    expandableStringWithSubexpressionStart _ statementList:? _ ")" _ expandableStringWithSubexpressionChars _ expandableStringWithSubexpressionEnd |
    expandableHereStringWithSubexpressionStart _ statementList:? _ ")" _ expandableHereStringWithSubexpressionChars _ expandableHereStringWithSubexpressionEnd
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
    expandableHereStringWithSubexpressionChars _ expandableHereStringWithSubexpressionPart
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
    "[" _ typeSpec _ "]"
    {%
        function(data) {
            return {
                type: "typeLiteral",
                data: data
            }
        }
    %}

typeSpec ->
    arrayTypeName _ newLines:? _ dimension:? _ "]" |
    genericTypeName _ newLines:? _ genericTypeArguments _ "]" |
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
    dimension _ ","
    {%
        function(data) {
            return {
                type: "dimension",
                data: data
            }
        }
    %}

genericTypeArguments ->
    typeSpec _ newLines:? |
    genericTypeArguments _ "," _ newLines:? _ typeSpec
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
    attributeList _ newLines:? _ attribute
    {%
        function(data) {
            return {
                type: "attributeList",
                data: data
            }
        }
    %}

attribute ->
    "[" _ newLines:? _ attributeName _ "(" _ attributeArguments _ newLines:? _ ")" _ newLines:? _ "]" |
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
    attributeArgument _ newLines:? _ "," _ attributeArguments
    {%
        function(data) {
            return {
                type: "attributeArguments",
                data: data
            }
        }
    %}

attributeArgument ->
    newLines:? _ expression |
    newLines:? _ simpleName |
    newLines:? _ simpleName _ "=" _ newLines:? _ expression
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
    inputElements:? _ signatureBlock:?
    {%
        function(data) {
            return {
                type: "input",
                data: data
            }
        }
    %}

inputElements ->
    inputElement |
    inputElements inputElement
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
    signatureBegin _ signature _ signatureEnd
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
    singleLineComments _ newLineCharacter _ singleLineComment
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

carriageReturnCharacter ->
    [\r] {% function() {} %}

lineFeedCharacter ->
    [\n] {% function() {}%}

newLines ->
    newLineCharacter |
    newLines _ newLineCharacter
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
    inputCharacter |
    inputCharacters inputCharacter
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
    "\u002D" |
    "\u2013" |
    "\u2014" |
    "\u2015"
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
    "#" |
    hashes "#"
    {%
        function(data) {
            let out = ""
            for (let i = 0; i < data[0].length; i++) {
                out += data[0][i]
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
            for (let i = 0; i < data[0].length; i++) {
                out += data[0][i]
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
    "$" _ variableScope:? _ variableCharacters |
    "@" _ variableScope:? _ variableCharacters |
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
    "${" _ variableScope:? _ bracedVariableCharacters _ "}"
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
            const out = [];
            for (let i = 0; i < data[0].data.length; i++) {
                out.push(data[0].data[i][0]);
            }
            return {
                type: "genericToken",
                data: out
            }
        }
    %}

genericTokenParts ->
    genericTokenPart:+
    {%
        function(data) {
            return {
                type: "genericTokenParts",
                data: data[0]
            }
        }
    %}

genericTokenPart ->
    expandableStringLiteral |
    verbatimHereStringLiteral |
    variable |
    genericTokenCharacter
    {% id %}
    # {%
    #     function(data) {
    #         return {
    #             type: "genericTokenPart",
    #             data: data[0]
    #         }
    #     }
    # %}

genericTokenCharacter ->
    [^{}();,|&$\u0060'"\r\n\s] |
    escapedCharacter
    {%
        function(data) {
            return {
                type: "genericTokenCharacter",
                data: data[0]
            }
        }
    %}

genericTokenWithSubexpressionStart ->
    genericTokenParts _ "$("

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
    "$":+
    # "$" |
    # dollars "$"

expandableHereStringLiteral ->
    "@" doubleQuoteCharacter _ newLineCharacter expandableHereStringCharacters:? newLineCharacter doubleQuoteCharacter "@"

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
    verbatimStringPart:+
    # verbatimStringPart |
    # verbatimStringCharacters verbatimStringPart

verbatimStringPart ->
    nonSingleQuoteCharacter |
    singleQuoteCharacter singleQuoteCharacter

verbatimHereStringLiteral ->
    "@" singleQuoteCharacter _ newLineCharacter verbatimHereStringCharacters:? newLineCharacter singleQuoteCharacter "@"

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

# Whitespace
_ -> (null | _ whitespace)
    {% function() {} %}
__ -> whitespace |
    __ whitespace
    {% function() {} %}
