#!/usr/bin/awk -f

# Usage:
#   awk -f neg.awk file.txt

BEGIN {
    IGNORECASE = 1

    # Space-separated negative terms.
    negative_words["no"]       = 1
    negative_words["not"]      = 1
    negative_words["never"]    = 1
    negative_words["none"]     = 1
    negative_words["nobody"]   = 1
    negative_words["nothing"]  = 1
    negative_words["neither"]  = 1
    negative_words["nowhere"]  = 1
    negative_words["hardly"]   = 1
    negative_words["barely"]   = 1
    negative_words["scarcely"] = 1
    negative_words["without"]  = 1
    negative_words["cannot"]   = 1
    negative_words["can't"]    = 1
    negative_words["won't"]    = 1
    negative_words["wouldn't"] = 1
    negative_words["couldn't"] = 1
    negative_words["shouldn't"]= 1
    negative_words["don't"]    = 1
    negative_words["doesn't"]  = 1
    negative_words["didn't"]   = 1
    negative_words["isn't"]    = 1
    negative_words["aren't"]   = 1
    negative_words["wasn't"]   = 1
    negative_words["weren't"]  = 1
    negative_words["neither"]  = 1
}

function normalize(word) {
    word = tolower(word)
    gsub(/^['"]+|['",.;:!?()]+$/, "", word)
    return word
}

function report(kind, text) {
    gsub(/[[:space:]]+/, " ", text)
    printf "%s:%d: %-24s %s\n",
           FILENAME, line_no, kind, text
}

{
    line_no++
    line = $0
    negative_count = 0
    negative_list = ""

    # Words, including apostrophes and hyphens.
    n = split(line, words, /[^[:alnum:]'’-]+/)

    for (i = 1; i <= n; i++) {
        word = normalize(words[i])

        if (word in negative_words) {
            negative_count++

            if (negative_list == "")
                negative_list = word
            else
                negative_list = negative_list ", " word

            report("negative construction", word)
        }
    }

    # Common multiword negative expressions.
    if (line ~ /[Nn]either[[:space:]]+.*[[:space:]]+nor/)
        report("paired negative construction", "neither ... nor")

    if (line ~ /[Nn]ot[[:space:]]+only[[:space:]]+.*[[:space:]]+but/)
        report("contrastive negative construction", "not only ... but")

    if (line ~ /[Nn]o[[:space:]]+longer/)
        report("negative phrase", "no longer")

    if (line ~ /[Ff]ar[[:space:]]+from/)
        report("negative phrase", "far from")

    # Very simple double-negative warning.
    # This is clause-insensitive and therefore deliberately conservative.
    if (negative_count >= 2)
        report("possible double negative", negative_list)
}
