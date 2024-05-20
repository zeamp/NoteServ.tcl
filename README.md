# noteserv.tcl v1.0 by zeamp
# https://www.zpvy.com

Eggdrop script for storing and displaying notes for users in every channel.
Syntax: !note <nickname> <message>

Notes are stored using SQLite3 and get deleted after being displayed.
If the backend (DCC/Partyline) output is too verbose, you can edit it.
