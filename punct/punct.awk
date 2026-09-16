#!/usr/bin/awk -f

# Approximation of a Writer's WorkBench-style punctuation checker.
# Totally vibe-coded at this point. Much testing and revision is needed.
#
# Usage:
#     awk -f punct.awk file.txt
#     ./punct.awk file.txt

BEGIN {
    FS = ""
    line_no = 0
    sentence_start_line = 1
    sentence = ""

    paren = 0
    bracket = 0
    brace = 0
    double_quote = 0
    single_quote = 0
}

function report(kind, text,    shown) {
    shown = text
    gsub(/[[:space:]]+/, " ", shown)
    printf "%s:%d: %-38s %s\n", \
           FILENAME, line_no, kind, shown
}

function count_words(s,    n, a, i, w) {
    n = split(s, a, /[^[:alnum:]'’-]+/)
    w = 0

    for (i = 1; i <= n; i++)
        if (a[i] ~ /[[:alnum:]]/)
            w++

    return w
}

# Return the word immediately before character position p.
function preceding_word(s, p,    left, word) {
    left = substr(s, 1, p - 1)

    if (match(left, /[[:alpha:]][[:alpha:].'-]*$/))
        word = substr(left, RSTART, RLENGTH)
    else
        word = ""

    return word
}

# Decide whether the period at position p is probably a sentence-ending
# period rather than a decimal point, abbreviation, initial, or ellipsis.
function is_sentence_period(s, p,    before, after, word) {
    before = (p > 1 ? substr(s, p - 1, 1) : "")
    after  = (p < length(s) ? substr(s, p + 1, 1) : "")

    # Decimal number, such as 3.14.
    if (before ~ /[[:digit:]]/ && after ~ /[[:digit:]]/)
        return 0

    # Ellipses.
    if (substr(s, p - 2, 3) == "..." ||
        substr(s, p - 1, 2) == ".."  ||
        substr(s, p, 3) == "...")
        return 0

    word = preceding_word(s, p)

    # Common abbreviations.
    if (word ~ /^(Mr|Mrs|Ms|Dr|Prof|Sr|Jr|St|Mt|No|Fig|Rev|Gen|Sgt|Col|Lt|etc)$/)
        return 0

    # A single-letter initial, as in "J. Smith".
    if (word ~ /^[[:alpha:]]$/ && after ~ /[[:space:]]/)
        return 0

    # A period followed immediately by a letter is not a boundary.
    if (after ~ /[[:alpha:]]/)
        return 0

    return 1
}

# Return the number of sentences found in s.
# The sentences are stored in the global array sentence_part[].
function split_sentences(s,    i, c, nextc, n, part) {
    delete sentence_part
    n = 0
    part = ""

    for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        part = part c

        if (c == "." && is_sentence_period(s, i)) {
            n++
            sentence_part[n] = part
            part = ""
        }
        else if (c == "!" || c == "?") {
            nextc = (i < length(s) ? substr(s, i + 1, 1) : "")

            # Keep ?! and !? together.
            if (nextc == "!" || nextc == "?") {
                i++
                part = part nextc
            }

            # Treat the mark as terminal only when followed by whitespace
            # or end of input. This avoids splitting unusual constructions.
            nextc = (i < length(s) ? substr(s, i + 1, 1) : "")

            if (nextc == "" || nextc ~ /[[:space:]]/) {
                n++
                sentence_part[n] = part
                part = ""
            }
        }
    }

    if (part != "") {
        n++
        sentence_part[n] = part
    }

    return n
}

function check_sentence(s, startline,    first, last, words, t) {
    t = s
    gsub(/^[[:space:]]+/, "", t)
    gsub(/[[:space:]]+$/, "", t)

    if (t == "")
        return

    first = substr(t, 1, 1)
    last = substr(t, length(t), 1)
    words = count_words(t)

    if (first ~ /[),.;:!?]/)
        printf "%s:%d: %-38s %s\n",
               FILENAME, startline, "leading punctuation", t

    if (last !~ /[.!?:"'”’)\]]/)
        printf "%s:%d: %-38s %s\n",
               FILENAME, startline, "possible missing ending", t

    if (words == 1 || words == 2)
        printf "%s:%d: %-38s %s\n",
               FILENAME, startline, "possible fragment", t

    if (words >= 40)
        printf "%s:%d: %-38s %s\n",
               FILENAME, startline, "long sentence", t

    # Conservative comma-splice heuristic.
    if (t ~ /,[[:space:]]+[[:upper:]][[:alpha:]'’-]*[[:space:]]+[[:alpha:]]+[[:space:]]+/)
        printf "%s:%d: %-38s %s\n",
               FILENAME, startline, "possible comma splice", t

    # Common introductory words and phrases.
    if (t ~ /^[[:space:]]*(However|Therefore|Moreover|Furthermore|Meanwhile|In addition|For example|In contrast|As a result|On the other hand)[[:space:]]+[[:upper:]]/)
        printf "%s:%d: %-38s %s\n",
               FILENAME, startline, "possible missing comma after introductory element", t

    # Simple series heuristic.
    if (t ~ /,[[:space:]]+[[:alnum:]'’-]+[[:space:]]+[[:alnum:]'’-]+[.!?]?$/)
        printf "%s:%d: %-38s %s\n",
               FILENAME, startline, "possible missing series comma", t
}

{
    line_no++
    line = $0

    # Local punctuation checks.

    if (line ~ /[[:space:]][,.;:!?]/)
        report("space before punctuation", line)

    if (line ~ /[,;:!?][[:alnum:]]/)
        report("missing space after punctuation", line)

    if (line ~ /([.!?,;:])\1+/)
        report("repeated punctuation", line)

    if (line ~ /(^|[[:space:]])[,.;:!?]/)
        report("punctuation after whitespace", line)

    if (line ~ /,[[:space:]]*and[[:space:]]*[,.]/)
        report("suspicious comma around and", line)

    if (line ~ /(^|[[:space:]])and[,.;:!?]/)
        report("punctuation after conjunction", line)

    # Track paired delimiters and quotes.
    for (i = 1; i <= length(line); i++) {
        c = substr(line, i, 1)

        if (c == "(")
            paren++
        else if (c == ")") {
            paren--
            if (paren < 0) {
                report("unmatched closing parenthesis", line)
                paren = 0
            }
        }
        else if (c == "[")
            bracket++
        else if (c == "]") {
            bracket--
            if (bracket < 0) {
                report("unmatched closing bracket", line)
                bracket = 0
            }
        }
        else if (c == "{")
            brace++
        else if (c == "}") {
            brace--
            if (brace < 0) {
                report("unmatched closing brace", line)
                brace = 0
            }
        }
        else if (c == "\"")
            double_quote = !double_quote
        else if (c == "'") {
            # Do not treat apostrophes in words as quotation marks.
            before = (i > 1 ? substr(line, i - 1, 1) : "")
            after  = (i < length(line) ? substr(line, i + 1, 1) : "")

            if (before !~ /[[:alpha:]]/ || after !~ /[[:alpha:]]/)
                single_quote = !single_quote
        }
    }

    # Accumulate physical lines into a logical paragraph/sentence stream.
    if (sentence == "") {
        sentence_start_line = line_no
        sentence = line
    }
    else {
        sentence = sentence " " line
    }

    # Extract complete sentences using the improved splitter.
    n = split_sentences(sentence)

    if (n > 1) {
        for (i = 1; i < n; i++)
            check_sentence(sentence_part[i], sentence_start_line)

        # Keep the incomplete final part for the next input line.
        sentence = sentence_part[n]
    }
}

END {
    # Check the final incomplete or unterminated sentence.
    check_sentence(sentence, sentence_start_line)

    if (paren > 0)
        printf "%s:%d: %-38s %s\n",
               FILENAME, line_no, "unclosed parenthesis", "("

    if (bracket > 0)
        printf "%s:%d: %-38s %s\n",
               FILENAME, line_no, "unclosed bracket", "["

    if (brace > 0)
        printf "%s:%d: %-38s %s\n",
               FILENAME, line_no, "unclosed brace", "{"

    if (double_quote)
        printf "%s:%d: %-38s %s\n",
               FILENAME, line_no, "unclosed double quote", "\""

    if (single_quote)
        printf "%s:%d: %-38s %s\n",
               FILENAME, line_no, "unclosed single quote", "'"
}
