#!/usr/bin/perl

# the "shebang" line tells the shell which excutable to use to parse the program

my $now = time; 

# $now will contain the time the program started as unix timestamp (in seconds since 1970).
# 
# scalar variables (numbers, strings etc. are prefixed with the $ sign
#
# "my" declares local variables

my ( $hrs, $min, $sec ) = ( localtime )[ 2, 1, 0 ]; 

# localtime returne a list of numbers, the first three being seconds, minutes and hours

our @time_strings = qw( hour minute second );

# array (list) variables are prefixed by the @ symbol
#
# qw( ... ) means "quote words", so we don't have to put the words individually in quotes and separate them by commas 
#
# "our" declares glabal variables


# defaults

my $msg = 'Countdown';
my $time_out = 600;
my $interval = 60;
my @msg;

for(@ARGV) {


# The global array @ARGV contains the command line parameters
#
# "for" loops over the items of a list. "foreach" means the same.
# 
# You can explicitely loop with for my $item (@list) { ... } or implicitely.
# In the latter case, the system variable $_ is used for the loop.


    if(m/^(\d\d?):(\d\d?)(:(\d\d?))?$/) {
        
        # A regular expression enclosed in m/ / is a pattern matching
        # It can be done explicitely $var =~ m/.../ or, if $_ is used, it's enough to
        # just write the pattern.
        
        # ^ marks the beginning of a string, $ the end
        # \d is a digit
        # everything followed by a ? is optional
        # ( ) mark groups. From left to right, every group can later be extracted by $1, $2, $3 etc.   
    
        # matches <HOURS>:<MINUTES>[:<SECONDS>] where HOURS, MINUTES and SECONDS can 
        # be double or single digit figures
        
        my ($alarm_hrs, $alarm_min, $alarm_sec) = ($1, $2, $4);
        
        $alarm_sec ||= 0;
        
        # if SECONDS weren't specified set them to zero
        
        $alarm_sec -= $sec;
        $alarm_min -= $min;
        $alarm_hrs -= $hrs;
        
        while($alarm_sec < 0) {
            $alarm_sec += 60;
            $alarm_min--;
        }
        while($alarm_min < 0) {
            $alarm_min += 60;
            $alarm_hrs--; 
        }
        while($alarm_hrs < 0) {
            $alarm_hrs += 24
        }
        $time_out = $alarm_sec + 60*($alarm_min + 60*$alarm_hrs);
        # the next statement means: leave it here and take the loop's next item
        
        next
    }
    if(m/^(\d+)(\w*)/) {
        my ($number, $quantifier) = ($1, $2);
        
        # \w is a "word character"
        # a + after something means, the pattern can occur many, but at least 1, time(s)
        # a * after something means, the pattern can occur many, but at least 0, times
        # will recognize plain numbers as minutes,
        # numbers followed by "h" or "H" and perhaps more letters as hours and
        # numbers followed by "s" or "S" and perhaps more letters as seconds
        
        $interval = $number * ( $quantifier =~ /^h/i ? 3600 : $quantifier =~ /^s/i ? 1 : 60 );
        
        # pattern matching followed by i means: case insensitive
        
        next
    }
    push(@msg, $_)
    
    # anything that doesn't matches the above patterns will be interpreted as text to 
    # be displayed with the notification, so it gets pushed to the end of the @msg list
}

$interval = $time_out if $interval == 0;

$msg = join(' ', @msg) if @msg;

my $sys_msg = $msg . ' ends in '. parse_time($time_out);

# strings are glued together by the "." operator

system('notify-send','-t',1000*$interval,$sys_msg);

# system executes a system command and returns to the program 

my $interval_notifier = 0;
$time_out += $now;

while($time_out > time) {
    if($interval_notifier >= $interval) {
        my $t = $time_out - time;
        $sys_msg = $msg . " ends in\n".parse_time($t);
        $interval = $t if $interval > $t;
        system('notify-send','-t',1000*$interval,$sys_msg);
        $interval_notifier = 0;
    }
    $interval_notifier++;
    sleep 1
}
( $hrs, $min, $sec ) = ( localtime )[2,1,0];

s/^(\d)$/0$1/ for ( $hrs, $min, $sec );
# make all numbers double digits
# s/ / / replaces something in the first block with something in the second 


$sys_msg = "It's $hrs:$min:$sec\n$msg ended";

exec('notify-send','-t',0,$sys_msg);

# exec executes a system command and leaves the program


sub parse_time {
# functions are called subroutines in Perl and declared with the keyword sub 
# parameters get stored in the array @_
#
# This sub takes a number like 3721 and returns a string like "1 hour, 2 minutes and 1 second"


    my $t = shift; 
    # using just shift pulls the first parameter from the array @_ and returns it. 
    
    return '0 seconds' unless $t;
    my @t  = (int($t/3600),int(($t % 3600)/60), $t % 60 );
    # @t = (hours, minutes, seconds)
    
    my @ts = map{ $t[$_] ? $t[$_].' '.$time_strings[$_].( $t[$_] == 1 ? '' : 's' ) : '' }( 0..2 );
    
    # map takes an array, here (0..2) = (0,1,2), applies the function between the { } to each element, the current 
    # element is always $_ and returns a new array.
    #
    # 0 is mapped to the empty string
    #
    # 1 is mapped to "1" + the time string ("hour", "minute", "second" )
    #
    # other numbers n are mapped to n + time string + "s" for plural
    
    
    
    splice(@ts,1,1) unless $ts[1];
    shift(@ts)      until  $ts[0];
    pop(@ts)        until  $ts[-1];
    splice(@ts, -1,0,' and ') if @ts > 1;
    splice(@ts, 1,0,', ')     if @ts > 3;
    return join('', @ts);
}

=pod

=head1 countdown.pl

A command line utility which makes use of Ubuntu's C<notify-send> utility 
to display a countdown on the user screen.

B<Written by Mina, free to use.>

=head1 Requisites

=head2 Perl

Perl should be present by default on practically all Linux system. If not, it can be installed with e.g.

=over 1

C<sudo apt install perl>

=back

=head2 C<notify-send>

The C<notify-send> utility is not installed by default on all systems. If not present, it can be installed with e.g.

=over 1

C<sudo apt install notify-send>

=back

=head1 Synopsis

=over 1

C<countdown.pl [ALARM TIME] [REMINDER INTERVAL] [COUNTDOWN NAME]>

=back

=head2 Options

All options are optional, do not require flags and don't need to be given in a particular order. Options are recognized 
by their format.

=head3 Alarm Time

The time when the countdown is supposed to end, given in 24 hours form, separated by colon(s) (":"):

=over 1

C<H:M[:S]>

=back

Times can be given in double or single digit numbers. Seconds are optional.

If no alarm time is given, it is set by default to 10 minutes in the future

=head3 Reminder Interval

By default, a C<notify-send> message is displayed all the time, containing the countdown's name and the time until it is finished.
This message is refreshed in fixed intervals, the "reminder interval". It is given as plain number, optionally followed by "h" or "s".

=over 1

C<N[h|s]>

=back 

The number is the reminder interval in minutes, if followed by "h" in hours, if followed by "s" in seconds. The letters can be given in
caps or small caps. Following alphanumerical characters are ignored. Other letters than "h" or "s" directly after the number are ignored
and the number is interpreted as minutes.

=over 1

=item

If no reminder interval is given, the default 1 minute is used.

=item

If the number 0 is given, there's only one message at the beginning of the countdown and one at the end. 

=back

=head3 Countdown Name

Every word not matching any of the above pattern will be interpreted as being part of the countdown's name. All words are joined 
by single spaces and displayed on to top of the reminder message. If no countdown name is given, "Countdown" is the default.  

=head1 Installation

=over 1

=item

B<Make sure, you have the C<notify-send> utility installed.>

=item

If you want, you can copy C<countdown.pl> e.g. to C</usr/local/bin> e.g. by C<sudo cp countdown.pl /usr/local/bin>. Of course, you can 
rename it as you please, getting rid e.g. of the C<.pl> suffix.

=item

Make sure to make the program executable, e.g. by C<chmod a+x INSTALLATION PATH/countdown.pl> 

=back

=head1 Tips

=over 1

=item

Note that the program only supports countdowns up to 24 hours.

=item

It is advisable, to run the program in the background by adding the ampersand character at the very end of the commang, e.g.

=over 2

C<countdown.pl 23:30 30s Time to sleep my dear &>

=back

=item

You can create your own manual page by running one of the commands (install if not present):

=over 2

=item

C<pod2text countdown.pl E<gt> countdown.txt>

=item 

C<pod2html countdown.pl E<gt> countdown.html>

=item

C<pod2man countdown.pl E<gt> countdown.man>

=back

=back

=cut
