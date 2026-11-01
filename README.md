# Writer's ScriptBench
Scripts to mostly duplicate the function
of missing or lost Writer's Workbench (WWB) utilities.
Some new scripts replace or extend functionality.

Some WWB utilities were rewritten from scratch with public licenses.
Others have original source available on TUHS, with uncertain licensing.
A few come from the BSD side.
Here's the list of utilities I'm aware of
(excluding formatters, macro packages, preprocessors, and postprocessors;
those are all available as released source or ground-up rewrites, or both).

| Name | Status | Notes |
|-----|-----|-----|
| abst | unknown | Abstractness evaluation; ArtsEngine or WordTangible might be replacements |
| acro | **Here** | Acronym check |
| checkmm | **Here** | Requires groff |
| deroff | **Here** | -w option not supported, pipe to *wordlist* instead |
| dictadd | unknown | Adds to diction & spell dictionaries |
| diction | **Available from [GNU diction](https://www.gnu.org/software/diction/)** | Improved but no dictadd |
| diversity | Here (maybe) | Word diversity — vibe-coded replacement |
| double | *unneeded*, GNU diction does this | Checks for double words |
| explain | *unneeded* | GNU diction does this with the -s (or --suggest) option |
| findbe | Here (maybe) | "Looks for syntax that may be difficult to understand" — vibe-coded replacement |
| hyphen | **Here** | Shows hyphenated words in *nroff* or *troff -a* output |
| morestyle | unknown | Runs abst, diversity, neg |
| neg | **Here** | Negative constructions — vibe-coded replacment |
| org | unknown | Prints first & last sentence of each paragraph |
| passive | **Here** | **New**, finds basic passive voice constructs |
| proofr | unknown | Ran spell, double, punct, and diction |
| prose | unknown | Ran style and sexist |
| punct | Here (maybe) | Punctuation check — vibe-coded replacement |
| reuseprep | Here (soon) | **New**, preps text for [reuse analysis](https://github.com/larrykollar/reuse_analyzer) |
| sexist | unknown | Looks for sexist words and phrases |
| spell | *unneeded* | Use aspell |
| spelladd | *unneeded* | aspell allows adding on the fly |
| spellwwb | *unneeded* | aspell has this functionality |
| splitrules | *unneeded* | Finds split infinitives, we don't worry about those now |
| style | *Bundled with GNU diction* | Improved |
| syl | *unneeded* | Average number of syllables per word (supported in GNU style) |
| wordlist | **Here** | **New**, replaces -w option in WSB deroff |
| wwb | unknown | Runs everything |

Of all these, deroff was the most frustrating.
GNU has a version, but it produces garbled output.
A BSD version on GitHub compiles (with some help)
but produces **no** output.
So the WSB version calls nroff
(turning off hyphenation on the command line)
to strip the markup.
If you've extended a macro package to turn on hyphenation,
you may end up with hyphenated words anyway.

Most of the WSB utilities work differently
from their WWB counterparts.
Check the manual page
for each utility, especially if you're familiar with the original
and want to see what's different.
