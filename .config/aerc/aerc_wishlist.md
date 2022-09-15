# AERC wishlist

- switch accounts during compose ([ticket](https://todo.sr.ht/~rjarry/aerc/72))
- preview emails during message list (i.e. preview pane)
- message list: show single line of body like outlook/gmail
- notmuch search: be able to get entire thread (notmuch can search like this so possible currently, but clunky, so could have a convenience function which wraps search terms in thread:)
- notmuch search II: if you are on a message, fetch it's thread and show only that
- proper image preview via sixels or kitty ([in progress](https://lists.sr.ht/~rjarry/aerc-devel/patches/35291))
- see side pane when messages are opened
- proper handling of message/rfc822 attachments ([mailing list discussion](https://lists.sr.ht/~rjarry/aerc-discuss/%3CCMFX6Y1EK9IN.3EDGQCN38PELF%40mashenka%3E))
- maildir support in notmuch accounts, likely via `notmuch insert` ([mailing list discussion](https://lists.sr.ht/~rjarry/aerc-discuss/%3CCME4HD5R5320.1OX7WHTBT4XPO%40mashenka%3E))
- show new mail in account tab name (maybe with parentheses?)
- do not quit aerc with unsaved message open
- persistent command history ([in progress](https://lists.sr.ht/~rjarry/aerc-devel/patches/35310))
- attach glob should not list hidden unless flag?
- save: empty save should assume current directory
- figure out the strings-all-over-the-terminal issue ([mailing list discussion](https://lists.sr.ht/~rjarry/aerc-discuss/%3CCMCE8KH71EYW.389PSC31IBYBG%40mashenka%3E))
- fuzzy finding on open links and a more intutive way to open links ([mailing list discussion](https://lists.sr.ht/~rjarry/aerc-discuss/%3CCMQHJJ60VUJX.1755Z40799MCZ%40mashenka%3E))
- preview attachments somehow in the review-before-send-screen
- unable to see all "to" addresses in message view
- automatic draft saving during compose
- maildir operation callback command? ([mailing list discussion](https://lists.sr.ht/~rjarry/aerc-discuss/%3CCMWBLIUO8AIN.2AKI83RNTGNH7%40mashenka%3E))
- undo message sending for X seconds?
- view of INBOX while writing mail ([mailing list discussion](https://lists.sr.ht/~rjarry/aerc-discuss/%3CCMWBLIUO8AIN.2AKI83RNTGNH7%40mashenka%3E#%3CCMWGBF579PWF.28Z2HZIRKXINL@TimBook-Arch%3E))

# solved

- ~~zoxide integration -> (see https://lists.sr.ht/~rjarry/aerc-devel/patches/35133)~~
