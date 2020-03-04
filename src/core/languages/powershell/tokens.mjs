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
        CmdletNameToken: {
            match: /[^$0-9(@\n][^ \t\n]*/,
            push: "cmdlet"
        },
        WhiteSpaceToken: /[ \t]+/
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
        CallArgumentSeparatorToken: {
            match: / \|/,
            pop: true
        },
        CommaToken: / \|/,
        WhiteSpaceToken: /[ \t]+/,
        ComparisonOperatorToken: /-eq|-ne|-ge|-gt|-lt|-le|-ieq|-ine|-ige|-igt|-ilt|-ile|-ceq|-cne|-cge|-cgt|-clt|-cle|-like|-notlike|-match|-notmatch|-ilike|-inotlike|-imatch|-inotmatch|-clike|-cnotlike|-cmatch|-cnotmatch|-contains|-notcontains|-icontains|-inotcontains|-ccontains|-cnotcontains|-isnot|-is|-as|-replace|-ireplace|-creplace/,
        AssignmentOperatorToken: /=|\+=|-=|\*=|\/=|%=/,
        LogicalOperatorToken: /-and|-or/,
        BitwiseOperatorToken: /-band|-bor/,
        RedirectionOperatorToken: /2>&1|>>|>|<<|<|>\||2>|2>>|1>>/,
        FunctionDeclarationToken: ["function", "filter"],
        ExpandableStringToken: {
            match: /".*"/
        },
        StringToken: {
            match: /'.*'/
        },
        VariableToken: /\$[0-9A-Za-z]+ | \${.+}/,
        ParameterToken: /-[A-Za-z]+[:]?/,
        MinusMinusToken: /--/,
        RangeOperatorToken: /\.\./,
        NumberToken: /\d+\.?\d*/,
        ReferenceOperatorToken: /\.|::|\[/,
        // ParameterArgumentToken: /[^-($0-9].*[^ \t]/,
        ParameterArgumentToken: /[^-($0-9|][^\r\n\t;}\]() |]*[^ \t|]/,
        UnaryOperatorToken: /!|-not|\+|-|-bnot| \[..*\]/,
        FormatOperatorToken: /-f/,
        LoopLabelToken: /[A-Za-z][0-9A-Za-z]*/,
        ParamToken: /param/,
        PrePostfixOperatorToken: /\+\+ | --/,
        MultiplyOperatorToken: /\* | \/ | %/,
        AdditionOperatorToken: /\+ | -/,
        AttributeSpecificationToken: /\[..*\]/,
        StatementSeparatorToken: {
            match: / ; | && | \|\| | [\r\n]+/,
            pop: true,
            lineBreaks: true
        }
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
