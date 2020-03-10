/**
 * Token definitions for PowerShell
 *
 * From Appendix C: https://www.manning.com/books/windows-powershell-in-action
 */

export default {
    main: {
        MultilineCommentToken: {
            match: /<#/,
            push: "multilineComment"
        },
        CommentToken: {
            match: /#/,
            push: "comment"
        },
        DataTypeToken: {
            match: /\[[^ \t\r\n]+\]/,
            push: "cmdlet"
        },
        VariableToken: {
            match: /\$[0-9A-Za-z]+|\${.+}/,
            push: "cmdlet"
        },
        WhiteSpaceToken: /[ \t]+/,
        ConditionalToken: {
            match: /[Ii][Ff]|[Ee][Ll][Ss][Ee][Ii][Ff]|[Ee][Ll][Ss][Ee]/,
            push: "cmdlet"
        },
        CmdletNameToken: {
            match: /[^$0-9(@\r\n][^ \t\r\n(]*/,
            push: "cmdlet"
        },
        StatementSeparatorToken: {
            match: /;|&&|\|\||[\r\n]+/,
            pop: true,
            lineBreaks: true
        },
        OpenBracketToken: /\(/,
        CloseBracketToken: /\)/
    },
    cmdlet: {
        MultilineCommentToken: {
            match: /<#/,
            push: "multilineComment"
        },
        CommentToken: {
            match: /#/,
            push: "comment"
        },
        OpenBracketToken: {
            match: /\(/,
            pop: true
        },
        CloseBracketToken: /\)/,
        OpenCurlyBracketToken: {
            match: /\{/,
            pop: true
        },
        CloseCurlyBracketToken: {
            match: /\}/,
            pop: true
        },
        StatementSeparatorToken: {
            match: /;|&&|\|\||[\r\n]+/,
            pop: true,
            lineBreaks: true
        },
        CallArgumentSeparatorToken: {
            match: /\|/,
            pop: true
        },
        CommaToken: /,/,
        DataTypeToken: /\[[^ \t\r\n]+\]/,
        WhiteSpaceToken: /[ \t]+/,
        ComparisonOperatorToken: /-eq|-ne|-ge|-gt|-lt|-le|-ieq|-ine|-ige|-igt|-ilt|-ile|-ceq|-cne|-cge|-cgt|-clt|-cle|-like|-notlike|-match|-notmatch|-ilike|-inotlike|-imatch|-inotmatch|-clike|-cnotlike|-cmatch|-cnotmatch|-contains|-notcontains|-icontains|-inotcontains|-ccontains|-cnotcontains|-isnot|-is|-as|-replace|-ireplace|-creplace/,
        AssignmentOperatorToken: /=|\+=|-=|\*=|\/=|%=/,
        LogicalOperatorToken: /-and|-or/,
        BitwiseOperatorToken: /-band|-bor/,
        RedirectionOperatorToken: /2>&1|>>|>|<<|<|>\||2>|2>>|1>>/,
        FunctionDeclarationToken: ["function", "filter"],
        ExpandableStringToken: {
            match: /"/,
            push: "ExpandableString"
        },
        StringToken: /'.*'/,
        VariableToken: /\$[0-9A-Za-z]+|\${.+}/,
        ParameterToken: /-[A-Za-z]+[:]?/,
        MinusMinusToken: /--/,
        RangeOperatorToken: /\.\./,
        NumberToken: /\d+\.?\d*/,
        ReferenceOperatorToken: /\.|::|\[/,
        // ParameterArgumentToken: /[^-($0-9].*[^ \t]/,
        ParameterArgumentToken: /[^-($0-9|][^\r\n\t;}\]() |]*[^ \t\r\n|]/,
        UnaryOperatorToken: /!|-not|\+|-|-bnot| \[..*\]/,
        FormatOperatorToken: /-f/,
        LoopLabelToken: /[A-Za-z][0-9A-Za-z]*/,
        PrePostfixOperatorToken: /\+\+ | --/,
        MultiplyOperatorToken: /\*|\/|%/,
        AdditionOperatorToken: /\+ | -/,
        AttributeSpecificationToken: /\[..*\]/
    },
    ExpandableString: {
        ExpandableStringToken: {
            match: /"/,
            pop: true
        },
        VariableToken: /\$[0-9A-Za-z]+|\${.+}/,
        StringText: /[^"\r\n$]+/
    },
    comment: {
        CommentText: /[^\r\n]+/,
        StatementSeparatorToken: {
            match: /[\r\n]+/,
            pop: true,
            lineBreaks: true
        }
    },
    multilineComment: {
        CommentText: {
            match: /[^#][^>]*/,
            lineBreaks: true
        },
        CloseMultilineCommentToken: {
            match: /#>/,
            pop: true
        }
    }
};
