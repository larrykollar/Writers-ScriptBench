#!/usr/bin/awk -f

# Usage:
#   awk -f diversity.awk file.txt
#
# Optional:
#   awk -v minfreq=2 -f diversity.awk file.txt

BEGIN {
    IGNORECASE = 1
    minfreq = (minfreq == "" ? 1 : minfreq)

    # Common stopwords. These are excluded only from the
    # "most frequent content words" report.
    split("a an the and or but if then else for to of in on at by "
          "from with without as is are was were be been being am "
          "I you he she it we they this that these those "
          "do does did have has had can could should would will "
          "may might must", stopwords)
}

function clean(word) {
    word = tolower(word)

    # Remove punctuation around a word.
    gsub(/^[-'’]+/, "", word)
    gsub(/[-'’,.;:!?()[\]{}"“”]+$/, "", word)

    return word
}

function is_stopword(word,    i) {
    for (i in stopwords)
        if (word == stopwords[i])
            return 1

    return 0
}

{
    # Split on anything that is not a letter, number, apostrophe,
    # or hyphen.
    n = split($0, fields, /[^[:alnum:]'’-]+/)

    for (i = 1; i <= n; i++) {
        word = clean(fields[i])

        if (word !~ /[[:alnum:]]/)
            continue

        tokens++
        frequency[word]++

        if (!(word in seen)) {
            seen[word] = 1
            types++
        }
    }
}

END {
    if (tokens == 0) {
        print "No words found."
        exit
    }

    ttr = types / tokens
    hapax = 0

    for (word in frequency) {
        if (frequency[word] == 1)
            hapax++
    }

    printf "Tokens:                 %d\n", tokens
    printf "Distinct words:         %d\n", types
    printf "Type-token ratio:       %.4f\n", ttr
    printf "Hapax words:            %d\n", hapax
    printf "Hapax proportion:       %.4f\n", hapax / types
    print ""
    print "Most frequent content words:"

    # Select the ten most frequent non-stopwords.
    for (rank = 1; rank <= 10; rank++) {
        best_word = ""
        best_count = 0

        for (word in frequency) {
            if (is_stopword(word))
                continue

            if (frequency[word] < minfreq)
                continue

            if (frequency[word] > best_count) {
                best_word = word
                best_count = frequency[word]
            }
        }

        if (best_word == "")
            break

        printf "  %-20s %d\n", best_word, best_count

        # Mark it so it is not selected again.
        frequency[best_word] = -1
    }
}
