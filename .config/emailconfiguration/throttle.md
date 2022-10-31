# Problem statement

I have multiple accounts, that I want synced to maildir folders and use notmuch
as a unified view on them within aerc. Some accounts have very large archive
folders, but actively used folders contain typical a few dozen messages at most.

This is currently achieved by running:
- one goimapnotify for each account
- and trying to run every minute:
   - mbsync -a (takes more than a minute)
   - notmuch new
   - msmtp -q
   - a notmuch tag to folder sync script

This is not fast enough when actively working with email, especially, when it is
the last thing I do with the laptop (i.e. I've had operations not synced by the
time I put the computer to sleep on multiple occasions), but is way too much
work when NOT working with email. Since notmuch can create queries over folders,
notmuch tag-folder sync is only active when changed on notmuch side (added tag).

# Possible solution

Run a _single_ server, that can be configured to:
- watch a subset of folders (NOT the large Archives) with inotify and run _only_
  corresponding mbsync channel
- run specifiable scripts/commands at specifiable intervals (e.g. to run a full
  sync every 10-15 minutes and run the addressbook every 12 hours)
- listen on given port to receive commands to sync specific mbsync channels
  and/or run a notmuch tag-folder sync update
- throttle running channels/notmuch sync to a given maximum frequency
