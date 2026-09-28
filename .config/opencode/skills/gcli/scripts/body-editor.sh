#!/bin/sh
# Non-interactive $EDITOR replacement for gcli.
# gcli runs "$EDITOR <tmpfile>"; this overwrites <tmpfile> with $GCLI_BODY_FILE.
cat "$GCLI_BODY_FILE" > "$1"
