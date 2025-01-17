# noteserv.tcl v1.4 by zeamp
https://www.abovelinks.com/ze

Eggdrop script for storing and displaying notes for users in a channel.
This script acts as a faux MemoServ / IRC shoutbox, letting you leave
notes for others who have left or will cycle the IRC channel.


Syntax: [PUBCHAN]

!noteserv <nickname> <message>


Alternate: [PRIVMSG]

/msg NoteServ !noteserv !noteserv <#channel> <nickname> <message>


Notes are stored using SQLite3 and get deleted after being displayed.
If the backend (DCC/Partyline) output is too verbose, you can edit it.
Notes are now recorded with a timestamp.

This script was written for EFnet and other IRC networks that don't have
normal IRC services (NickServ, MemoServ), or for someone who wants to
run their own private note system that isn't network dependant.
