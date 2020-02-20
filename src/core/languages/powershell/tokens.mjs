/**
 * Token definitions for PowerShell
 *
 * From Appendix C: https://www.manning.com/books/windows-powershell-in-action
 */

export default {
    CallArgumentSeparatorToken: / \|/,
    CommaToken: / \|/,
    WhiteSpaceToken: /[ \t]+/,
    ComparisonOperatorToken: /-eq|-ne|-ge|-gt|-lt|-le|-ieq|-ine|-ige|-igt|-ilt|-ile|-ceq|-cne|-cge|-cgt|-clt|-cle|-like|-notlike|-match|-notmatch|-ilike|-inotlike|-imatch|-inotmatch|-clike|-cnotlike|-cmatch|-cnotmatch|-contains|-notcontains|-icontains|-inotcontains|-ccontains|-cnotcontains|-isnot|-is|-as|-replace|-ireplace|-creplace/,
    AssignmentOperatorToken: /=|\+=|-=|\*=|\/=|%=/,
    LogicalOperatorToken: /-and|-or/,
    BitwiseOperatorToken: /-band|-bor/,
    RedirectionOperatorToken: /2>&1|>>|>|<<|<|>\||2>|2>>|1>>/,
    FunctionDeclarationToken: /function|filter/,
    ExpandableStringToken: /".*"/,
    StringToken: /'.*'/,
    VariableToken: /\$[0-9A-Za-z]+ | \${.+}/,
    ParameterToken: /-[A-Za-z]+[:]?/,
    MinusMinusToken: /--/,
    RangeOperatorToken: /\.\./,
    NumberToken: /\d+\.?\d*/,
    ReferenceOperatorToken: /\.|::|\[/,
    CmdletNameToken: /[^$0-9(@\n][^ \t\n]*/,
    ParameterArgumentToken: /[^-($0-9].*[^ \t]/,
    UnaryOperatorToken: /!|-not|\+|-|-bnot| \[..*\]/,
    FormatOperatorToken: /-f/,
    LoopLabelToken: /[A-Za-z][0-9A-Za-z]*/,
    ParamToken: /param/,
    PrePostfixOperatorToken: /\+\+ | --/,
    MultiplyOperatorToken: /\* | \/ | %/,
    AdditionOperatorToken: /\+ | -/,
    AttributeSpecificationToken: /\[..*\]/,
    StatementSeparatorToken: / ; | && | \|\| | [\r\n]+/
};
