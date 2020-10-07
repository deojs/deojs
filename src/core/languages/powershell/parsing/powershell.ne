# Powershell grammar
# From https://www.microsoft.com/en-us/download/details.aspx?id=36389

@include "../../unicode/categories/unicode_Zs.ne"
@include "../../unicode/categories/unicode_Zl.ne"
@include "../../unicode/categories/unicode_Zp.ne"
@include "../../unicode/categories/unicode_Llu.ne"
@include "../../unicode/categories/unicode_Lm.ne"
# @include "../../unicode/categories/unicode_Lo.ne" # Can't import this as it's too big!
@include "../../unicode/categories/unicode_Nd.ne"

@include "./lexical.ne"

# Syntactic grammar
# Statements
scriptBlock ->
    (comment:+):? newLines:? paramBlock:? (_ statementTerminators):? _ scriptBlockBody:?
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
                type: "scriptBlock",
                data: out
            }
        }
    %}

paramBlock ->
    newLines:? (_ attributeList):? (_ newLines):? _ "param" (_ newLines):?
        _ "(" _ parameterList:? (_ newLines):? _ ")"
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
                type: "paramBlock",
                data: out
            }
        }
    %}

parameterList ->
    (scriptParameter |
    parameterList (_ newLines):? _ "," _ scriptParameter)
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
                type: "parameterList",
                data: out
            }
        }
    %}

scriptParameter ->
    newLines:? (_ attributeList):? (_ newLines):? _ variable __ scriptParameterDefault:?
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
                type: "scriptParameter",
                data: out
            }
        }
    %}

scriptParameterDefault ->
    newLines:? "=" newLines:? expression
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
                type: "scriptParameterDefault",
                data: out
            }
        }
    %}

scriptBlockBody ->
    (namedBlockList |
    statementList)
    {%
        function(data) {
            data = data[0];
            return {
                type: "scriptBlockBody",
                data: data[0]
            }
        }
    %}

namedBlockList ->
    namedBlock:+
    {%
        function(data) {
            return {
                type: "namedBlockList",
                data: data[0]
            }
        }
    %}

namedBlock ->
    blockName _ statementBlock _ statementTerminators:?
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
                type: "namedBlock",
                data: out
            }
        }
    %}

blockName ->
    ("dynamicparam"i |
    "begin"i |
    "process"i |
    "end"i)
    {%
        function(data) {
            data = data[0];
            return {
                type: "blockName",
                data: data[0]
            }
        }
    %}

statementBlock ->
    "{" (_ newLines):? (_ statementList):? (_ newLines):? _ "}"
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
                type: "statementBlock",
                data: out
            }
        }
    %}

statementList ->
    (statement |
    statementList (_ newLines):? _ statement)
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
                type: "statementList",
                data: out
            }
        }
    %}

statement ->
    (comment |
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
    pipeline) _ statementTerminators
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
                type: "statement",
                data: out
            }
        }
    %}

statementTerminator ->
    (";" |
    newLineCharacter)
    {%
        function(data) {
            data = data[0];
            return {
                type: "statementTerminator",
                data: data[0]
            }
        }
    %}

statementTerminators ->
    (statementTerminator |
    statementTerminators _ statementTerminator)
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
                type: "statementTerminators",
                data: out
            }
        }
    %}

ifStatement ->
    "if"i (_ newLines):? _ "(" (_ newLines):? _ pipeline (_ newLines):? _ ")" (_ newLines):? _ statementBlock (_ newLines):? (_
        elseifClauses):? (_ elseClause):?
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
                type: "ifStatement",
                data: out
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
    newLines:? _ "elseif"i (_ newLines):? _ "(" (_ newLines):? _ pipeline (_ newLines):? _ ")" _ statementBlock
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
                type: "elseifClause",
                data: out
            }
        }
    %}

elseClause ->
    newLines:? _ "else"i _ statementBlock
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
                type: "elseClause",
                data: out
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
    (switchStatement |
    foreachStatement |
    forStatement |
    whileStatement |
    doStatement)
    {%
        function(data) {
            data = data[0];
            return {
                type: "labeledStatement",
                data: data[0]
            }
        }
    %}

switchStatement ->
    "switch"i (_ newLines):? (_ switchParameters):? _ switchCondition _ switchBody
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
                type: "switchStatement",
                data: out
            }
        }
    %}

switchParameters ->
    (switchParameter |
    switchParameters __ switchParameter)
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
                type: "switchParameters",
                data: out
            }
        }
    %}

switchParameter ->
    ("-regex"i |
    "-wildcard"i |
    "-exact"i |
    "-casesensitive"i |
    "-parallel"i)
    {%
        function(data) {
            data = data[0];
            return {
                type: "switchParameter",
                data: data[0]
            }
        }
    %}

switchCondition ->
    "(" (_ newLines):? _ pipeline (_ newLines):? _ ")" |
    "-file"i (_ newLines):? _ switchFilename
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
                type: "switchCondition",
                data: out
            }
        }
    %}

switchFilename ->
    (commandArgument |
    primaryExpression)
    {%
        function(data) {
            data = data[0];
            return {
                type: "switchFilename",
                data: data[0]
            }
        }
    %}

switchBody ->
    newLines:? _ "{" (_ newLines):? _ switchClauses _ "}"
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
                type: "switchBody",
                data: out
            }
        }
    %}

switchClauses ->
    switchClause:+
    {%
        function(data) {
            return {
                type: "switchClauses",
                data: data[0]
            }
        }
    %}

switchClause ->
    switchClauseCondition _ statementBlock (_ statementTerminators):?
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
                type: "switchClause",
                data: out
            }
        }
    %}

switchClauseCondition ->
    (commandArgument |
    primaryExpression)
    {%
        function(data) {
            data = data[0];
            return {
                type: "switchClauseCondition",
                data: data[0]
            }
        }
    %}

foreachStatement ->
    "foreach"i (_ newLines):? (_ foreachParameter):? (_ newLines):? _
        "(" (_ newLines):? _ variable (_ newLines):? _ "in"i (_ newLines):? _ pipeline (_ newLines):? _ ")" _ statementBlock
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
                type: "foreachStatement",
                data: out
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
    "for"i (_ newLines):? _ (
        "(" (_ newLines):? (_ forInitializer):? _ statementTerminator
        (_ newLines):? (_ forCondition):? _ statementTerminator
        (_ newLines):? (_ forIterator):? (_ newLines):? _ ")" _ statementBlock |
        "(" (_ newLines):? (_ forInitializer):? _ statementTerminator
        (_ newLines):? (_ forCondition):? (_ newLines):? _ ")" _ statementBlock |
        "(" (_ newLines):? (_ forInitializer):? (_ newLines):? _ ")" _ statementBlock
    )
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
                type: "forStatement",
                data: out
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
    "while"i (_ newLines):? _ "(" newLines:? _ whileCondition (_ newLines):? _ ")" statementBlock
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
                type: "whileStatement",
                data: out
            }
        }
    %}

doStatement ->
    ("do"i statementBlock (_ newLines):? _ "while"i (_ newLines):? _ "(" _ whileCondition (_ newLines):? _ ")" |
    "do"i statementBlock (_ newLines):? _ "until"i (_ newLines):? _ "(" _ whileCondition (_ newLines):? _ ")")
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
                type: "doStatement",
                data: out
            }
        }
    %}

whileCondition ->
    newLines:? _ pipeline
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
                type: "whileCondition",
                data: out
            }
        }
    %}

functionStatement ->
    ("function"i (_ newLines):? _ functionName _ functionParameterDeclaration:? _ "{" scriptBlock _ "}" |
    "filter"i (_ newLines):? _ functionName _ functionParameterDeclaration:? _ "{" scriptBlock _ "}" |
    "workflow"i (_ newLines):? _ functionName _ functionParameterDeclaration:? _ "{" scriptBlock _ "}")
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
                type: "functionStatement",
                data: out
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
    (newLines _):? "(" _ parameterList (_ newLines):? _ ")"
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
                type: "functionParameterDeclaration",
                data: out
            }
        }
    %}

flowControlStatement ->
    ("break"i __ labelExpression:? |
    "continue"i __ labelExpression:? |
    "throw"i __ pipeline:? |
    "return"i __ pipeline:? |
    "exit"i __ pipeline:?)
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
                type: "flowControlStatement",
                data: out
            }
        }
    %}

labelExpression ->
    (simpleName |
    unaryExpression)
    {%
        function(data) {
            data = data[0];
            return {
                type: "labelExpression",
                data: data[0]
            }
        }
    %}

trapStatement ->
    "trap"i (_ newLines):? (_ typeLiteral):? (_ newLines):? _ statementBlock
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
                type: "trapStatement",
                data: out
            }
        }
    %}

tryStatement ->
    ("try"i _ statementBlock _ catchClauses |
    "try"i _ statementBlock _ finallyClause |
    "try"i _ statementBlock _ catchClauses _ finallyClause)
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
                type: "tryStatement",
                data: out
            }
        }
    %}

catchClauses ->
    catchClause:+
    {%
        function(data) {
            return {
                type: "catchClauses",
                data: data[0]
            }
        }
    %}

catchClause ->
    (_ newLines):? _ "catch"i (_ catchTypeList):? _ statementBlock
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
                type: "catchClause",
                data: out
            }
        }
    %}

catchTypeList ->
    (newLines:? _ typeLiteral |
    catchTypeList (_ newLines):? _ "," (_ newLines):? _ typeLiteral)
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
                type: "catchTypeList",
                data: out
            }
        }
    %}

finallyClause ->
    newLines:? _ "finally"i _ statementBlock
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
                type: "finallyClause",
                data: out
            }
        }
    %}

dataStatement ->
    "data"i (_ newLines _ | __) dataName (_ dataCommandsAllowed):? _ statementBlock
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
                type: "dataStatement",
                data: out
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
                type: "dataCommandsAllowed",
                data: out
            }
        }
    %}

dataCommandsList ->
    (newLines:? _ dataCommand |
    dataCommandsList _ "," (_ newLines):? _ dataCommand)
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
                type: "dataCommandsList",
                data: out
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
    (assignmentExpression |
    expression (_ redirections:?) (_ pipelineTail):? |
    command (_ verbatimCommandArgument):? (_ pipelineTail):?)
    {%
        function(data) {
            data = data[0];
            let out = [];
            for (let i = 0; i < data.length; i++) {
                if (data[i] !== null && data[i] !== undefined && !Array.isArray(data[i])) {
                    out.push(data[i]);
                }
                if (Array.isArray(data[i])) {
                    const arrPush = [];
                    for (let y = 0; y < data[i].length; y++) {
                        if (data[i][y] !== null && data[i][y] !== undefined) {
                            arrPush.push(data[i][y]);
                        }
                    }
                    if (arrPush.length > 0) {
                        out.push(arrPush);
                    }
                }
            }
            if (out.length === 1) {
                out = out[0];
            }
            return {
                type: "pipeline",
                data: out
            }
        }
    %}

assignmentExpression ->
    expression _ assignmentOperator _ statement
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
                type: "assignmentExpression",
                data: out
            }
        }
    %}

pipelineTail ->
    ("|" (_ newLines):? _ command |
    "|" (_ newLines):? _ command _ pipelineTail)
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
                type: "pipelineTail",
                data: out
            }
        }
    %}

command ->
    (commandName (__ commandElements):? |
    commandInvocationOperator (_ commandModule:?) commandNameExpression (_ commandElements):?)
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
                type: "command",
                data: out
            }
        }
    %}

commandInvocationOperator ->
    ("&" |
    ".")
    {%
        function(data) {
            data = data[0];
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
    (genericToken |
    genericTokenWithSubexpression)
    {%
        function(data, location, reject) {
            data = data[0];
            const recurse = function (obj) {
                if (obj === null || obj === undefined) {
                    return "";
                }
                if (typeof obj === "string") {
                    return obj;
                }
                if (Array.isArray(obj)) {
                    let out = "";
                    for (let i = 0; i < obj.length; i++) {
                        out += recurse(obj[i]);
                    }
                    return out;
                }
                if (Object.prototype.hasOwnProperty.call(obj, "data")) {
                    return recurse(obj.data);
                }

                return "";
            };

            if (recurse(data) === "if") {
                return reject;
            }

            return {
                type: "commandName",
                data: data[0]
            }
        }
    %}

genericTokenWithSubexpression ->
    genericTokenWithSubexpressionStart (_ statementList):? _ ")" commandName # No whitespace between ) and commandName!
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
                type: "genericTokenWithSubexpression",
                data: out
            }
        }
    %}

commandNameExpression ->
    (commandName |
    primaryExpression)
    {%
        function(data) {
            data = data[0];
            return {
                type: "commandNameExpression",
                data: data[0]
            }
        }
    %}

commandElements ->
    (commandElement |
    commandElements (__ | _ "," _) commandElement)
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
                type: "commandElements",
                data: out
            }
        }
    %}

commandElement ->
    (commandParameter |
    commandArgument |
    redirection)
    {%
        function(data) {
            data = data[0];
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
    ("--%" verbatimCommandArgumentChars |
    verbatimCommandArgumentChars)
    {%
        function(data) {
            data = data[0];
            return {
                type: "verbatimCommandArgument",
                data: data
            }
        }
    %}

redirections ->
    (redirection |
    redirections _ redirection)
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
                type: "redirections",
                data: out
            }
        }
    %}

redirection ->
    (mergingRedirectionOperator |
    fileRedirectionOperator _ redirectedFileName)
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
                type: "redirection",
                data: out
            }
        }
    %}

redirectedFileName ->
    (commandArgument |
    primaryExpression)
    {%
        function(data) {
            data = data[0];
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
    (bitwiseExpression |
    logicalExpression _ "-and"i (_ newLines):? _ bitwiseExpression |
    logicalExpression _ "-or"i (_ newLines):? _ bitwiseExpression |
    logicalExpression _ "-xor"i (_ newLines):? _ bitwiseExpression)
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
                type: "logicalExpression",
                data: out
            }
        }
    %}

bitwiseExpression ->
    (comparisonExpression |
    bitwiseExpression _ "-band" (_ newLines):? _ comparisonExpression |
    bitwiseExpression _ "-bor" (_ newLines):? _ comparisonExpression |
    bitwiseExpression _ "-bxor" (_ newLines):? _ comparisonExpression)
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
                type: "bitwiseExpression",
                data: out
            }
        }
    %}

comparisonExpression ->
    (additiveExpression |
    comparisonExpression _ comparisonOperator (_ newLines):? _ additiveExpression)
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
                type: "comparisonExpression",
                data: out
            }
        }
    %}

additiveExpression ->
    (multiplicativeExpression |
    additiveExpression _ "+" (_ newLines):? _ multiplicativeExpression |
    additiveExpression _ dash (_ newLines):? _ multiplicativeExpression)
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
                type: "additiveExpression",
                data: out
            }
        }
    %}

multiplicativeExpression ->
    (formatExpression |
    multiplicativeExpression _ "*" (_ newLines):? _ formatExpression |
    multiplicativeExpression _ "/" (_ newLines):? _ formatExpression |
    multiplicativeExpression _ "%" (_ newLines):? _ formatExpression)
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
                type: "multiplicativeExpression",
                data: out
            }
        }
    %}

formatExpression ->
    (rangeExpression |
    formatExpression _ formatOperator (_ newLines):? _ rangeExpression)
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
                type: "formatExpression",
                data: out
            }
        }
    %}

rangeExpression ->
    (arrayLiteralExpression |
    rangeExpression _ ".." (_ newLines):? _ arrayLiteralExpression)
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
                type: "rangeExpression",
                data: out
            }
        }
    %}

arrayLiteralExpression ->
    (unaryExpression |
    unaryExpression _ "," (_ newLines):? _ arrayLiteralExpression)
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
                type: "arrayLiteralExpression",
                data: out
            }
        }
    %}

unaryExpression ->
    (primaryExpression |
    expressionWithUnaryOperator)
    {%
        function(data) {
            return {
                type: "unaryExpression",
                data: data[0]
            }
        }
    %}

expressionWithUnaryOperator ->
    ("," (_ newLines):? _ unaryExpression |
    "-not"i (_ newLines):? _ unaryExpression |
    "!" (_ newLines):? _ unaryExpression |
    "-bnot"i (_ newLines):? _ unaryExpression |
    "+" (_ newLines):? _ unaryExpression |
    dash (_ newLines):? _ unaryExpression |
    preIncrementExpression |
    preDecrementExpression |
    castExpression |
    "-split"i (_ newLines):? _ unaryExpression |
    "-join"i (_ newLines):? _ unaryExpression)
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
                type: "expressionWithUnaryOperator",
                data: out
            }
        }
    %}

preIncrementExpression ->
    "++" (_ newLines):? _ unaryExpression
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
                type: "preIncrementExpression",
                data: out
            }
        }
    %}

preDecrementExpression ->
    dashdash (_ newLines):? _ unaryExpression
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
                type: "preDecrementExpression",
                data: out
            }
        }
    %}

castExpression ->
    typeLiteral _ unaryExpression
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
                type: "castExpression",
                data: out
            }
        }
    %}

attributedExpression ->
    typeLiteral _ variable
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
                type: "attributedExpression",
                data: out
            }
        }
    %}

primaryExpression ->
    (value |
    memberAccess |
    elementAccess |
    invocationExpression |
    postIncrementExpression |
    postDecrementExpression)
    {%
        function(data) {
            data = data[0];
            return {
                type: "primaryExpression",
                data: data[0]
            }
        }
    %}

value ->
    (parenthesizedExpression |
    subExpression |
    arrayExpression |
    scriptBlockExpression |
    hashLiteralExpression |
    literal |
    typeLiteral |
    variable)
    {%
        function(data) {
            data = data[0];
            return {
                type: "value",
                data: data[0]
            }
        }
    %}

parenthesizedExpression ->
    "(" (_ newLines):? _ pipeline (_ newLines):? _ ")"
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
                type: "parenthesizedExpression",
                data: out
            }
        }
    %}

subExpression ->
    "$(" (_ newLines):? (_ statementList):? (_ newLines):? _ ")"
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
                type: "subExpression",
                data: out
            }
        }
    %}

arrayExpression ->
    "@(" (_ newLines):? (_ statementList):? (_ newLines):? _ ")"
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
                type: "arrayExpression",
                data: out
            }
        }
    %}

scriptBlockExpression ->
    "{" (_ newLines):? _ scriptBlock (_ newLines):? _ "}"
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
                type: "scriptBlockExpression",
                data: out
            }
        }
    %}

hashLiteralExpression ->
    "@{" (_ newLines):? (_ hashLiteralBody):? (_ newLines):? _ "}"
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
                type: "hashLiteralExpression",
                data: out
            }
        }
    %}

hashLiteralBody ->
    (hashEntry |
    hashLiteralBody _ statementTerminators _ hashEntry)
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
                type: "hashLiteralBody",
                data: out
            }
        }
    %}

hashEntry ->
    keyExpression _ "=" (_ newLines):? _ statement
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
                type: "hashEntry",
                data: out
            }
        }
    %}

keyExpression ->
    (simpleName |
    unaryExpression)
    {%
        function(data) {
            data = data[0];
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
                type: "postIncrementExpression",
                data: out
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
    (primaryExpression "." memberName |
    primaryExpression "::" memberName)
    {%
        function(data) {
            data = data[0];
            return {
                type: "memberAccess",
                data: data
            }
        }
    %}

elementAccess -> # No whitespace between primaryExpression and "["
    primaryExpression "[" (_ newLines):? _ expression (_ newLines):? _ "]"
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
                type: "elementAccess",
                data: out
            }
        }
    %}

invocationExpression -> # No whitespace after primaryExpression
    (primaryExpression "." memberName _ argumentList |
    primaryExpression "::" memberName _ argumentList)
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
                type: "invocationExpression",
                data: out
            }
        }
    %}

argumentList ->
    "(" (_ argumentExpressionList):? (_ newLines):? _ ")"
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
                type: "argumentList",
                data: out
            }
        }
    %}

argumentExpressionList ->
    (argumentExpression |
    argumentExpression (_ newLines):? _ "," _ argumentExpressionList)
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
                type: "argumentExpressionList",
                data: out
            }
        }
    %}

argumentExpression ->
    newLines:? _ logicalArgumentExpression
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
                type: "argumentExpression",
                data: out
            }
        }
    %}

logicalArgumentExpression ->
    (bitwiseArgumentExpression |
    logicalArgumentExpression _ "-and"i (_ newLines):? _ bitwiseArgumentExpression |
    logicalArgumentExpression _ "-or"i (_ newLines):? _ bitwiseArgumentExpression |
    logicalArgumentExpression _ "-xor"i (_ newLines):? _ bitwiseArgumentExpression)
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
                type: "logicalArgumentExpression",
                data: out
            }
        }
    %}

bitwiseArgumentExpression ->
    (comparisonArgumentExpression |
    bitwiseArgumentExpression _ "-band"i (_ newLines):? _ comparisonArgumentExpression |
    bitwiseArgumentExpression _ "-bor"i (_ newLines):? _ comparisonArgumentExpression |
    bitwiseArgumentExpression _ "-bxor"i (_ newLines):? _ comparisonArgumentExpression)
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
                type: "bitwiseArgumentExpression",
                data: out
            }
        }
    %}

comparisonArgumentExpression ->
    (additiveArgumentExpression |
    comparisonArgumentExpression _ comparisonOperator (_ newLines):? _ additiveArgumentExpression)
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
                type: "comparisonArgumentExpression",
                data: out
            }
        }
    %}

additiveArgumentExpression ->
    (multiplicativeArgumentExpression |
    additiveArgumentExpression _ "+" (_ newLines):? _ multiplicativeArgumentExpression |
    additiveArgumentExpression _ dash (_ newLines):? _ multiplicativeArgumentExpression)
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
                type: "additiveArgumentExpression",
                data: out
            }
        }
    %}

multiplicativeArgumentExpression ->
    (formatArgumentExpression |
    multiplicativeArgumentExpression _ "*" (_ newLines):? _ formatArgumentExpression |
    multiplicativeArgumentExpression _ "/" (_ newLines):? _ formatArgumentExpression |
    multiplicativeArgumentExpression _ "%" (_ newLines):? _ formatArgumentExpression)
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
                type: "multiplicativeArgumentExpression",
                data: out
            }
        }
    %}

formatArgumentExpression ->
    (rangeArgumentExpression |
    formatArgumentExpression _ formatOperator (_ newLines):? _ rangeArgumentExpression)
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
                type: "formatArgumentExpression",
                data: out
            }
        }
    %}

rangeArgumentExpression ->
    (unaryExpression |
    rangeExpression _ ".." (_ newLines):? _ unaryExpression)
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
                type: "rangeArgumentExpression",
                data: out
            }
        }
    %}

memberName ->
    (simpleName |
    stringLiteral |
    stringLiteralWithSubexpression |
    expressionWithUnaryOperator |
    value)
    {%
        function(data) {
            data = data[0];
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
    (expandableStringWithSubexpressionStart (_ statementList):? _ ")" _ expandableStringWithSubexpressionChars _ expandableStringWithSubexpressionEnd |
    expandableHereStringWithSubexpressionStart (_ statementList):? _ ")" _ expandableHereStringWithSubexpressionChars _ expandableHereStringWithSubexpressionEnd)
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
                type: "expandableStringLiteralWithSubexpression",
                data: out
            }
        }
    %}

expandableStringWithSubexpressionChars ->
    (expandableStringWithSubexpressionPart |
    expandableStringWithSubexpressionChars expandableStringWithSubexpressionPart)
    {%
        function(data) {
            data = data[0];
            return {
                type: "expandableStringWithSubexpressionChars",
                data: data
            }
        }
    %}

expandableStringWithSubexpressionPart ->
    (subExpression |
    expandableStringPart)
    {%
        function(data) {
            data = data[0];
            return {
                type: "expandableStringWithSubexpressionPart",
                data: data[0]
            }
        }
    %}

expandableHereStringWithSubexpressionChars ->
    (expandableHereStringWithSubexpressionPart |
    expandableHereStringWithSubexpressionChars _ expandableHereStringWithSubexpressionPart)
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
                type: "expandableHereStringWithSubExpressionPart",
                data: out
            }
        }
    %}

expandableHereStringWithSubexpressionPart ->
    (subExpression |
    expandableHereStringPart)
    {%
        function(data) {
            data = data[0];
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
                type: "typeLiteral",
                data: out
            }
        }
    %}

typeSpec ->
    (arrayTypeName (_ newLines):? (_ dimension):? _ "]" |
    genericTypeName (_ newLines):? _ genericTypeArguments _ "]" |
    typeName)
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
                type: "typeSpec",
                data: out
            }
        }
    %}

dimension ->
    ("," |
    dimension _ ",")
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
                type: "dimension",
                data: out
            }
        }
    %}

genericTypeArguments ->
    (typeSpec _ newLines:? |
    genericTypeArguments _ "," (_ newLines):? _ typeSpec)
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
                type: "genericTypeArguments",
                data: out
            }
        }
    %}

# Attributes
attributeList ->
    (attribute |
    attributeList (_ newLines):? _ attribute)
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
                type: "attributeList",
                data: out
            }
        }
    %}

attribute ->
    ("[" (_ newLines):? _ attributeName _ "(" _ attributeArguments (_ newLines):? _ ")" (_ newLines):? _ "]" |
    typeLiteral)
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
                type: "attribute",
                data: out
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
    (attributeArgument |
    attributeArgument (_ newLines):? _ "," _ attributeArguments)
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
                type: "attributeArguments",
                data: out
            }
        }
    %}

attributeArgument ->
    (newLines:? _ expression |
    newLines:? _ simpleName |
    newLines:? _ simpleName _ "=" (_ newLines):? _ expression)
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
                type: "attributeArgument",
                data: out
            }
        }
    %}
