WHY USE PEG

As an example; try using Regex to extract and ISO formatted date (For example: 2024-05-22T21:17:18.345Z) and you get something like this:

    /(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2})\.(\d+)Z/

That will work well enough, but it is not easy on the eye or immediately obvious what you are trying to extract.

Now write a PEG example for the same ISO formatted date and you get something like:

    digit <- [0-9]+
    datetime <- date 'T' time 'Z'
    date <- digit '-' digit '-' digit
    time <- digit ':' digit ':' digit ( '.' digit )? 

NOTE:
* An extension has been requested to allow default templated variables that look like regex equivalent.

    For example, the following definition would be added as a default expression allowing it to be used without further definition:

    %d <- [0-9]+

    THIS IS NOT CURRENTLY IMPLEMENTED

* An extension has been requested to allow limitation on number of matches

    for example:

    ([0-9]^2) would only match two digits and then proceed. 

    if used with default templates, you could shorten this to {%d^2}

    THIS IS NOT CURRENTLY IMPLEMENTED

PEG PARSER
----------

REFERENCES:
    https://people.seas.harvard.edu/~chong/pubs/gpeg_sle21.pdf

a <- c / d

a       Rule name
<-      Defintion symbol
c       

!       NOT operator (Succeeds if p does not match)
&       Positive lookup (Successd if p matches but consumes no input)
        &p is equivalent to !!p
/       Choice operator. Only tries next option if first option fails.
.       Any matching character
+       One or more of preceeding match
*       (Kleene Operator) - Matches Zero or More
|       Matches first is a set of alterative options (choice)

@       Search for pattern
~       Prefix before literals to denote case-insensitive matching
%       Character encoding

MEMOIZATION
The notation {{p}} is used to mark a pattern for memoization


NOTED PATTERNS:
!.      EOI (End of Input) Succeeds if it is not possible to accept another character

        Usually defined as:
            EOI <- !.

        Be careful when using this as it can lead to an infinate loop (See Common Issue Below)

@E      Equivalent to (!E .)* E


FUNCTIONS


SEQUENCE
Success if all options match, null if any one fail
    
PEG:        example -> ( i"Deep" _ i"into" _ i"that" _ i"darkness" _ i"peering" )
Function:   SEQUENCE([...])

Options:

    match( example, "Deep into that darkness peering" ) = MATCH
    match( example, "Deep into that darkness falling" ) = FAIL

    ERROR: Literal "peering" expected at 1,25

CHOICE

NOT PREDICATE
Success only if pattern matches
Does not consume any input

    example -> ( "foo" !"bar" )

    match( example, "foobar" )      = FAIL
    match( example, "foo fighter" ) = MATCH 

    On failure it generates "example found at 1"

    example "foobar" -> ( "foo" !"bar" )
    On failure it generates "foobar found at 1"

    #example -> ( "foo" !"bar" )
    On failure it generates no message

* OPERATOR (Zero or more)
Always successful.

    example -> "-"*

    match( example, "2345" ) = MATCH    ""
    match( example, "-234" ) = MATCH    "-"
    match( example, "----" ) = MATCH    "----"


? OPERATOR (Optional / Zero or One)
Always successful.

    example -> "-"? NUMBER

    match( example, "-345" ) = MATCH
    match( example, "2345" ) = MATCH


+ OPERATOR (One or more)
Successful if at least one match, only fails with no matches

    example -> [0-9]+

    match( example, "1234" ) = MATCH
    match( example, "-234" ) = FAILURE

COMMON ISSUES

E*
Zero Or More can match an empty result that could lead to an [infinate loop].

!E
Not Predicate returns an empty result that could lead to an [infinate loop].

&E
And Predicate returns an empty result that could lead to an [infinate loop].

SYMBOL <- [+-/*]
The use of a "-" in a character set is reserved. If you need the "-" symbol; it must be the first or last character otherwise it is used as a range operator.

SYMBOL <- [+-/*]    == "+" | "," | "-" | "." | "/" | "*"
SYMBOL <- [-+/*]    == "-" | "+" | "/" | "*"
SYMBOL <- [+/*-]    == "+" | "/" | "*" | "-"

In the first example; the range "+" to "/" is selected, followed by a "*"

Left Recursion

    The following syntax is allowed; but leads to an infinate loop as it is impossible to evaluate:

    SYNTAX <- SYNTAX / "a"

    In this case; the non-terminal "SYNTAX" is used to lookup the rule, which results in another lookup to "SYNTAX" etc.
  
    You can usually get around this by re-writing the expression, for example:

    SYNTAX <- "a"*

Infinate Loops
If an expression that returns an empty result (E*, !E, &E) is placed in a pattern that repeats (E*, E+) the cursor does not
increment and the parser will hang.

    EXAMPLE <- EOI*
    EXAMPLE <- (&.)*

In a simple loop; this is usally easy to debug, but the loop may exist several steps down in nested syntax which can be very difficult
to identify.

OPTIONAL SYMBOLS
Sometimes you may want to select between one or more symbols:

    SYMBOL <- "a" / "b" / "*" / "+"

This will work; but will be slower than using a character set:

    SYMBOL <- [ab*+]





