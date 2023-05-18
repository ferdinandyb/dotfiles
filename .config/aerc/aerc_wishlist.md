# AERC wishlist

## notmuch related
- search: be able to get entire thread (notmuch can search like this so possible currently, but clunky, so could have a convenience function which wraps search terms in thread:)
- search II: if you are on a message, fetch it's thread and show only that
- when modify-labels move the message out of the message list select the next message
- currently, you need to run a `check-mail` command to update the view, but it would be good to have this without needing any `check-mail` command

## imap related
- rename folders like isync
- be able to handle root dirs where everything is under `INBOX.`

## other
- see side pane when messages are opened
- do not quit aerc with unsaved message open
- attach glob should not list hidden unless flag? ([ticket](https://todo.sr.ht/~rjarry/aerc/83))
- automatic draft saving during compose
- maildir operation callback command? ([mailing list discussion](https://lists.sr.ht/~rjarry/aerc-discuss/%3CCMWBLIUO8AIN.2AKI83RNTGNH7%40mashenka%3E))
- undo message sending for X seconds? ([ticket](https://todo.sr.ht/~rjarry/aerc/84))
- view of INBOX while writing mail ([mailing list discussion](https://lists.sr.ht/~rjarry/aerc-discuss/%3CCMWBLIUO8AIN.2AKI83RNTGNH7%40mashenka%3E#%3CCMWGBF579PWF.28Z2HZIRKXINL@TimBook-Arch%3E))
- gmail like warning when sender is using a different domain then the actual email?
- when archiving the last message in a folder the tab should be closed and the view return to the account tab (showing the empty message list)
- be able to toggle sidebar
- if a new mail arrives into an empty Inbox nothing is selected -> maybe something should be?
- color different types of tabs differently
- show "has attachment" icon in message list ([mailing list discussion](https://lists.sr.ht/~rjarry/aerc-discuss/%3CCN6LJSLI2Y7J.H66FQ3S3T44C%40rob-itx-mini%3E#%3CCN6MOF6FJLVY.1VO7VC9MZVB8C@hades.moritz.sh%3E))
- sort setting with [ui:X=Y] seem to be broken
- ability to have a "unified" notmuch account to show actual maildir account as
  receiving account
- mouse scrolling in view should scroll message instead of cycling through parts (the underlying terminal emulater needs to be patched)

# solved

- zoxide integration -> (see https://lists.sr.ht/~rjarry/aerc-devel/patches/35133)
- persistent command history ([in progress](https://lists.sr.ht/~rjarry/aerc-devel/patches/35310))
- save: empty save should assume current directory (already worked, set:  `default-save-path=.`)
- switch accounts during compose ([ticket](https://todo.sr.ht/~rjarry/aerc/72))
- preview emails during message list (i.e. preview pane)
- proper image preview via sixels or kitty ([in progress](https://lists.sr.ht/~rjarry/aerc-devel/patches/35291)) (via kitty directly)
- unable to see all "to" addresses in message view ([ticket](https://todo.sr.ht/~rjarry/aerc/85))
- figure out the strings-all-over-the-terminal issue ([mailing list discussion](https://lists.sr.ht/~rjarry/aerc-discuss/%3CCMCE8KH71EYW.389PSC31IBYBG%40mashenka%3E))
- maildir support in notmuch accounts, likely via `notmuch insert` ([mailing list discussion](https://lists.sr.ht/~rjarry/aerc-discuss/%3CCME4HD5R5320.1OX7WHTBT4XPO%40mashenka%3E))
- proper handling of message/rfc822 attachments ([mailing list discussion](https://lists.sr.ht/~rjarry/aerc-discuss/%3CCMFX6Y1EK9IN.3EDGQCN38PELF%40mashenka%3E)) (wrote caeml utility + incoming patch from Koni handling eml)
- preview attachments somehow in the review-before-send-screen ([ticket](https://todo.sr.ht/~rjarry/aerc/86))
- show new mail in account tab name (maybe with parentheses? [ticket](https://todo.sr.ht/~rjarry/aerc/82))

# proved unnecessary

- message list: show single line of body like outlook/gmail (was not solved but split preview serves the same purpose)
- send encrypted email (this actually always worked with the :encrypt command)
- fuzzy finding on open links and a more intutive way to open links ([mailing list discussion](https://lists.sr.ht/~rjarry/aerc-discuss/%3CCMQHJJ60VUJX.1755Z40799MCZ%40mashenka%3E)) (solved using kitty ctrl+shift+e binding)
