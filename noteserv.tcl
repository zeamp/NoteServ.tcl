#!/usr/bin/env tclsh
#
# noteserv.tcl v1.1 by zeamp
# https://www.zpvy.com
#
# Eggdrop script for storing and displaying notes for users in every channel.
# Syntax: !note <nickname> <message>
#
# Notes are stored using SQLite3 and get deleted after being displayed.
# If the backend (DCC/Partyline) output is too verbose, you can edit it.
#

package require sqlite3

# Initialize SQLite database
sqlite3 db noteserv.db
db eval {
    CREATE TABLE IF NOT EXISTS notes (
        channel TEXT,
        nick TEXT,
        sender TEXT,
        message TEXT,
        timestamp TEXT,
        PRIMARY KEY (channel, nick)
    );
}

# Add a note for a user
proc add_note {nick host handle channel arg} {
    global db
    if {[llength $arg] < 2} {
        putserv "NOTICE $nick :NoteServ Usage: !note nickname message"
        return
    }
    set target [lindex $arg 0]
    set message [join [lrange $arg 1 end] " "]
    set timestamp [clock format [clock seconds] -format "%m-%d-%Y %H:%M"]
    db eval {
        INSERT OR REPLACE INTO notes (channel, nick, sender, message, timestamp) VALUES ($channel, $target, $nick, $message, $timestamp);
    }
    putserv "NOTICE $nick :Note for $target set successfully."
    putlog "Note set for $target in channel $channel by $nick: $message at $timestamp"
}

# Display a note for a user when they join the channel
proc show_note {nick uhost handle channel} {
    global db
    putlog "User $nick joined $channel, checking for notes."
    set result [db eval {
        SELECT sender, message, timestamp FROM notes WHERE channel = $channel AND nick = $nick;
    }]
    putlog "Query result: $result"

    if {[llength $result] > 0} {
        set sender [lindex $result 0]
        set message [lindex $result 1]
        set timestamp [lindex $result 2]
        putlog "Note found for $nick in $channel: $message from $sender at $timestamp"
        putserv "PRIVMSG $channel :Hi $nick - You have a note from $sender: $message  ($timestamp)"
        db eval {
            DELETE FROM notes WHERE channel = $channel AND nick = $nick;
        }
        putlog "Note deleted for $nick in $channel after displaying."
    } else {
        putlog "No note found for $nick in $channel."
    }
}

# Bind the public command for setting notes
bind pub - "!note" add_note

# Bind the event for displaying notes when users join the channel
bind join - * show_note

putlog "NoteServ v1.1 by zeamp is now loaded."
