# noteserv.tcl v1.3 by zeamp
https://www.zpvy.com

Eggdrop script for storing and displaying notes for users in a channel.
This script acts as a faux MemoServ / IRC shoutbox, letting you leave
notes for others who have left or will cycle the IRC channel.


Syntax:

!noteserv nickname message


Notes are stored using SQLite3 and get deleted after being displayed.
If the backend (DCC/Partyline) output is too verbose, you can edit it.
Notes are now recorded with a timestamp.

This script was written for EFnet and other IRC networks that don't have
normal IRC services (NickServ, MemoServ). Nicknames stored are CaSe sensitive,
as we assume that "Player1" and "player1" are two different people.
