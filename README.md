# Writer's ScriptBench
Scripts to mostly duplicate the function of missing or lost Writer's Workbench (WWB) utilities.
Some new scripts replace or extend functionality.

Some WWB utilities were rewritten from scratch with public licenses.
Others have original source available on TUHS, with uncertain licensing.
A few come from the BSD side.
Here's the list of utilities I'm aware of
(excluding formatters, macros, preprocessors, and postprocessors;
those are all available as released source or ground-up rewrites, or both).

| Name | Status | Notes |
|-----|-----|-----|
| abst | unknown | Abstractness evaluation; ArtsEngine or WordTangible might be replacements |
| acro | **Here** | Acronym check |
| checkmm | **Here** | Requires groff |
| deroff | **Here** | -w option not supported, pipe to *wordlist* instead |
| dictadd | unknown | Adds to diction & spell dictionaries |
| diction | Available from [GNU diction](https://www.gnu.org/software/diction/) | Improved but no dictadd |
| double | *unneeded*, GNU diction does this | Checks for double words |
| explain | *unneeded* | GNU diction does this with the -s (or --suggest) option |
| findbe | unknown | "Looks for syntax that may be difficult to understand" |
| hyphen | **Here** | Shows hyphenated words in *nroff* output |
| morestyle | unknown | "Abstract" words, word diversity, negative constructions |
| org | unknown | Prints first & last sentence of each paragraph |
| punct | unknown | Punctuation check (commas, periods in/out of quotes |
| reuseprep | Here (soon) | **New**, preps text for [reuse analysis](https://github.com/larrykollar/reuse_analyzer) |
| sexist | unknown | Looks for sexist words and phrases |
| spell | *unneeded* | Use aspell |
| spelladd | *unneeded* | aspell allows adding on the fly |
| spellwwb | *unneeded* | aspell has this functionality |
| splitrules | *unneeded* | Finds split infinitives, we don't worry about those now |
| style | Bundled with GNU diction | Improved |
| syl | *unneeded* | Average number of syllables per word (supported in GNU style) |
| wordlist | **Here** | **New**, replaces -w option in WSB deroff |

Of all these, deroff was the most frustrating.
GNU has a version, but it produces garbled output.
A BSD version on GitHub compiles (with some help) but produces **no** output.
So the WSB version calls nroff (turning off hyphenation on the command line)
to strip the markup.

Most of the WSB utilities work differently
from their WWB counterparts.
Check the manual page
for each utility, especially if you're familiar with the original
and want to see what's different.
