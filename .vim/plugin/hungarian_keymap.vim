" set langmap=\
"             \ő[,
"             \Ő{,
"             \ú],
"             \Ú},
"             \é:,
"             \á`,
"             \ű',
"             \ö<,
"             \ü>,
"             \ó=
"
"
" Langmap is broken currently, see https://github.com/vim/vim/issues/3018
" This means we need to manually add the required mappings. Unfortunately,
" while langmap would work for arbitrary stuff (e.g. translate úú -> ]], in
" any mode). For mappings where the actual target mapping is something like
" ]b, we can get away with úb, but for double mappings, we need to spell them
" out explicitly, because vim will look for a nonexistent úú mapping
" otherwise. We also need to spell it out for all modes explicitly.
"
" Since the amount of double mappings would blow up, we only add ones that we
" know are actually used, for the single ones we add everything.

nmap ő [
xmap ő [
omap ő [

nmap ú ]
omap ú ]
xmap ú ]

nmap őő [[
nmap úú ]]
nmap őú []
nmap úő ][

nmap Ő {
xmap Ő {
omap Ő {

nmap Ú }
omap Ú }
xmap Ú }

nmap ö <
xmap ö <
omap ö <

nmap ü >
xmap ü >
omap ü >

nmap ó =
xmap ó =
omap ó =
