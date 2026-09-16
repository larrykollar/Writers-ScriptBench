#!/usr/bin/awk -f

# Usage:
#   awk -f findbe.awk file.txt

BEGIN {
    IGNORECASE = 1
}

function show_context(line, start, end,    left, right) {
    left = substr(line, start - 35, 35)
    right = substr(line, end + 1, 45)
    gsub(/[[:space:]]+/, " ", left)
    gsub(/[[:space:]]+/, " ", right)

    return left "[" substr(line, start, end - start + 1) "]" right
}

{
    line_no++
    line = $0

    # Forms of "to be", including common contractions.
    pattern = "(am|is|are|was|were|be|been|being|\\047m|\\047s|\\047re|\\047ve|isn\\047t|aren\\047t|wasn\\047t|weren\\047t)"

    pos = 1

    while (match(substr(line, pos), "(^|[^[:alpha:]\\047-])" pattern "([^[:alpha:]\\047-]|$)")) {
        start = pos + RSTART - 1
        text = substr(line, start, RLENGTH)

        # Remove a leading non-word delimiter from the reported match.
        while (text ~ /^[^[:alpha:]\\047-]/) {
            text = substr(text, 2)
            start++
        }

        word_end = start + length(text) - 1
        following = substr(line, word_end + 1, 35)

        # Basic heuristic:
        #   is/was + -ing or past participle => likely auxiliary
        #   is/was + adjective/noun/prepositional phrase => likely copular
        if (following ~ /^[[:space:]]+[[:alpha:]][[:alpha:]'-]*ing([[:space:]]|$)/ ||
            following ~ /^[[:space:]]+[[:alpha:]][[:alpha:]'-]*ed([[:space:]]|$)/)
            kind = "likely auxiliary"
        else
            kind = "possible copula"

        printf "%s:%d: %-18s %s\n",
               FILENAME, line_no, kind,
               show_context(line, start, word_end)

        pos = word_end + 1
    }
}
