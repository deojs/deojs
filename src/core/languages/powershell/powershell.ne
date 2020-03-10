# Grammar definitions for PowerShell
# From Appendix C: https://www.manning.com/books/windows-powershell-in-action

# Statement List
StatementBlockRule -> "{" StatementListRule "}"

StatementListRule -> StatementRule [ StatementSeparatorToken StatementRule ]*

# Statement
StatementRule -> IfStatementRule
    | SwitchStatementRule
    | ForEachStatementRule
    | ForWhileStatementRule
    | DoWhileStatementRule
    | FunctionDeclarationRule
    | ParameterDeclarationRule
    | FlowControlStatementRule
    | TrapStatementRule
    | FinallyStatementRule
    | PipelineRule

# Pipeline
PipelineRule -> AssignmentStatement
    | FirstPipelineElement [ "|" CmdletCall ]*

AssignmentStatementRule -> LValueExpression AssignmentOperatorToken PipelineRule

LValueExpression -> LValue [? |? LValue]*

LValue -> SimpleLValue PropertyOrArrayReferenceOperator*

SimpleLValue -> AttributeSpecificationToken* VariableToken

FirstPipelineElement -> ExpressionRule
    | CmdletCall

CmdletCall -> [ "&" | "." | null ] [ Name | ExpressionRule ] [ ParameterToken | ParameterArgumentToken | PostfixOperatorRule | RedirectionRule ]*

RedirectionRule -> RedirectionOperatorToken PropertyOrArrayReferenceRule

# If statement
IfStatementRule -> "if" "(" PipelineRule ")" StatementBlockRule [ "elseif" "(" PipelineRule ")"] StatementBlockRule ]* [ "else" StatementBlockRule ]{0|1}

# Switch statement
SwitchStatementRule -> "switch" ["-regex" | "-wildcard" | "-exact"]{0|1}
    ["-caseinsensitive"]{0|1}
    ["-file" PropertyOrArrayReferenceRule |
        "(" PipelineRule ")" ]
    "{" [
        ["default" | ParameterArgumentToken |
            PropertyOrArrayReferenceRule | StatementBlockRule ]
        StatementBlockRule ]+ "}"

# Foreach statement
ForEachStatementRule -> LoopLabelToken{0|1} "foreach" "(" VariableToken
    "in" PipelineRule ")" StatementBlockRule

# For and while statements
ForWhileStatementRule -> LoopLabelToken{0|1} "while" "(" PipelineRule{0|1} ";"
    PipelineRule{0|1} ";" PipelineRule{0|1} ")"
        StatementBlockRule

# Do/while and do/until statements
DoWhileStatementRule -> LoopLabelToken{0|1} "do" StatementBlockRule ["while" | "until"]
    "("PipelineRule")"

# Trap statement
TrapStatementRule -> "trap" AttributeSpecificationToken{0|1} StatementBlockRule

# Finally statement
FinallyStatementRule -> "finally" StatementBlockRule

# Flow control
FlowControlStatementRule -> ["break" | "continue"]
    [PropertyNameToken | PropertyOrArrayReferenceRule]{0|1} |
    "return" PipelineRule

# Function declarations
FunctionDeclarationRule -> FunctionDeclarationToken ParameterArgumentToken
    [ "(" ParameterDeclarationExpressionRule ")" ]
        CmdletBodyRule

CmdletBodyRule -> "{" [ "(" ParameterDeclarationExpressionRule ")" ]
    [ "begin" StatementBlock |
        "process" StatementBlock |
        "end" StatementBlock ]* |
        StatementList "}"

# Parameter declarations
ParameterDeclarationRule -> ParameterDeclarationToken "("
    ParameterDeclarationExpressionRule ")"

ParameterDeclarationExpressionRule -> ParameterWithInitializer
    [ CommaToken ParameterWithInitializer ]*

ParameterWithInitializer -> SimpleLValue [ "=" ExpressionRule ]

# Expression
ExpressionRule -> LogicalExpressionRule

LogicalExpressionRule -> BitwiseExpressionRule
    [LogicalOperatorToken BitwiseExpressionRule]*

BitwiseExpressionRule -> ComparisonExpressionRule [BitwiseOperatorToken ComparisonExpressionRule]*

ComparisonExpressionRule -> AddExpressionRule
    [ ComparisonOperatorToken AddExpressionRule ]*

AddExpressionRule -> MultiplyExpressionRule
    [ AdditionOperatorToken MultiplyExpressionRule ]*

MultiplyExpressionRule -> FormatExpressionRule
    [ MultiplyOperatorToken FormatExpressionRule ]

FormatExpressionRule -> RangeExpressionRule
    [ FormatOperatorToken RangeExpressionRule ]*

RangeExpressionRule -> ArrayLiteralRule [ RangeOperatorToken ArrayLiteralRule ]*

ArrayLiteralRule -> PostfixOperatorRule [ CommaToken PostfixOperatorRule ]*

PostfixOperatorRule -> LValueExpression PrePostfixOperatorToken |
    PropertyOrArrayReferenceRule

PropertyOrArrayReferenceRule -> ValueRule PropertyOrArrayReferenceOperator*

PropertyOrArrayReferenceOperator -> "[" ExpressionRule "]" |
    "." [ PropertyNameToken ParseCallRule{0|1} | ValueRule ]

ParseCallRule -> "(" ArrayLiteralRule ")"

# Value
ValueRule -> "(" AssignmentStatementRule ")"
    | "$(" StatementListRule ")"
    | "@(" StatementListRule ")"
    | CmdletBodyRule
    | "@{" HashLiteralRule "}"
    | UnaryOperatorToken PropertyOrArrayReferenceRule
    | AttributeSpecificationToken PropertyOrArrayReferenceRule
    | AttributeSpecificationToken
    | PrePostfixOperatorToken LValue
    | NumberToken
    | StringToken
    | ExpandableStringToken [StringText | VariableToken]* ExpandableStringToken
    | VariableToken

HashLiteralRule -> KeyExpression "=" PipelineRule [ StatementSeparatorToken
    HashLiteralRule ]*
