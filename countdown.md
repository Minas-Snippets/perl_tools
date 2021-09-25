  * countdown.pl
  * Requisites
    * Perl
    * notify-send
  * Synopsis
    * Options
      * Alarm Time
      * Reminder Interval
      * Countdown Name
  * Installation
  * Tips

# countdown.pl

A command line utility which makes use of Ubuntu's `notify-send` utility to
display a countdown on the user screen.

**Written by Mina, free to use.**

# Requisites

## Perl

Perl should be present by default on practically all Linux system. If not, it
can be installed with e.g.

`sudo apt install perl`

## `notify-send`

The `notify-send` utility is not installed by default on all systems. If not
present, it can be installed with e.g.

`sudo apt install notify-send`

# Synopsis

`countdown.pl [ALARM TIME] [REMINDER INTERVAL] [COUNTDOWN NAME]`

## Options

All options are optional, do not require flags and don't need to be given in a
particular order. Options are recognized by their format.

### Alarm Time

The time when the countdown is supposed to end, given in 24 hours form,
separated by colon(s) (":"):

`H:M[:S]`

Times can be given in double or single digit numbers. Seconds are optional.

If no alarm time is given, it is set by default to 10 minutes in the future

### Reminder Interval

By default, a `notify-send` message is displayed all the time, containing the
countdown's name and the time until it is finished. This message is refreshed
in fixed intervals, the "reminder interval". It is given as plain number,
optionally followed by "h" or "s".

`N[h|s]`

The number is the reminder interval in minutes, if followed by "h" in hours,
if followed by "s" in seconds. The letters can be given in caps or small caps.
Following alphanumerical characters are ignored. Other letters than "h" or "s"
directly after the number are ignored and the number is interpreted as
minutes.

  * If no reminder interval is given, the default 1 minute is used.

  * If the number 0 is given, there's only one message at the beginning of the countdown and one at the end.

### Countdown Name

Every word not matching any of the above pattern will be interpreted as being
part of the countdown's name. All words are joined by single spaces and
displayed on to top of the reminder message. If no countdown name is given,
"Countdown" is the default.

# Installation

  * **Make sure, you have the`notify-send` utility installed.**

  * If you want, you can copy `countdown.pl` e.g. to `/usr/local/bin` e.g. by `sudo cp countdown.pl /usr/local/bin`. Of course, you can rename it as you please, getting rid e.g. of the `.pl` suffix.

  * Make sure to make the program executable, e.g. by `chmod a+x INSTALLATION PATH/countdown.pl`

# Tips

  * Note that the program only supports countdowns up to 24 hours.

  * It is advisable, to run the program in the background by adding the ampersand character at the very end of the commang, e.g.

`countdown.pl 23:30 30s Time to sleep my dear &`

  * You can create your own manual page by running one of the commands (install if not present):

    * `pod2text countdown.pl > countdown.txt`

    * `pod2html countdown.pl > countdown.html`

    * `pod2man countdown.pl > countdown.man`

