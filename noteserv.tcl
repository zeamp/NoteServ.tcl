#!/usr/bin/env tclsh
#
# noteserv.tcl v1.3 by zeamp
# https://www.zpvy.com
#
# Eggdrop script for storing and displaying notes for users in every channel.
#
# Notes are stored using SQLite3 and get deleted after being displayed.
# If the backend (DCC/Partyline) output is too verbose, you can edit it.
#
#
# CHANGELOG (v1.2 - v1.3)
#
# Changed !note command to !noteserv
# Added setting notes via PRIVMSG (optional, admins)
#
#
# Syntax: [PUBCHAN] !noteserv <nickname> <message>
# Alternate: [PRIVMSG] /msg NoteServ !noteserv !noteserv <#channel> <nickname> <message>
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
        putserv "NOTICE $nick :NoteServ Usage: !noteserv nickname message"
        return
    }
    set target [lindex $arg 0]
    set message [join [lrange $arg 1 end] " "]
    set timestamp [clock format [clock seconds] -format "%m-%d-%Y %H:%M"]
    db eval {
        INSERT OR REPLACE INTO notes (channel, nick, sender, message, timestamp) VALUES ($channel, $target, $nick, $message, $timestamp);
    }
    putserv "NOTICE $nick :Note for $target set successfully. Notes will expire after 5 years."
    putlog "Note set for $target in channel $channel by $nick: $message at $timestamp"
}

# Add a note via PRIVMSG
proc privmsg_note {nick uhost handle text} {
    global db
    putlog "Received PRIVMSG from $nick: $text"  ;# Debug log

    # Remove any extra whitespace and split the text into parts
    set cleaned_text [string trim $text]
    set parts [split $cleaned_text " "]

    putlog "Parsed parts: $parts"  ;# Debug log

    # Check if the first part is "!noteserv" and there are enough arguments
    if {[llength $parts] < 4 || [string tolower [lindex $parts 0]] ne "!noteserv"} {
        putlog "Invalid PRIVMSG format or command: not enough arguments"  ;# Debug log
        putlog "Expected format: !noteserv #channel nickname message"
        putlog "Received parts count: [llength $parts]"
        putlog "Received parts: $parts"
        return
    }

    # Extract the command parts
    set channel [lindex $parts 1]
    set target [lindex $parts 2]
    set message [join [lrange $parts 3 end] " "]
    set timestamp [clock format [clock seconds] -format "%m-%d-%Y %H:%M"]

    putlog "Setting note for $target in $channel from $nick: $message"  ;# Debug log

    db eval {
        INSERT OR REPLACE INTO notes (channel, nick, sender, message, timestamp) VALUES ($channel, $target, $nick, $message, $timestamp);
    }

    putserv "NOTICE $nick :Note for $target in $channel set successfully. Notes will expire after 5 years."
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

# Delete notes older than 5 years
proc delete_old_notes {} {
    global db
    set five_years_ago [clock scan "5 years ago"]
    db eval {
        DELETE FROM notes WHERE strftime('%s', timestamp) < $five_years_ago;
    }
    putlog "Deleted notes older than 5 years."
}

# Bind the public command for setting notes
bind pub - "!noteserv" add_note

# Bind the event for displaying notes when users join the channel
bind join - * show_note

# Bind the PRIVMSG command for setting notes
bind msg - "!noteserv" privmsg_note

# Bind the DCC partyline command to delete old notes
bind dcc n - delete_old_notes

putlog "NoteServ v1.3 by zeamp is now loaded."
