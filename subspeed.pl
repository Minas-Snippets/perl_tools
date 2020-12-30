#!/usr/bin/perl -w

=pod

=head1 subspeed.pl 

version 0.1

(c) by Mina, 2020

Free software under the GNU public licence 3.0 

https://www.gnu.org/licenses/gpl-3.0.en.html

=head2 Abstract

Program to linearly change timestamps in a subtitle (*.srt) file. 
It is meant to offset the "PAL acceleration" of videos.

=head2 Usage

C<subspeed.pl I<infile> [+|-]>

The program doesn't change the actual file: It reads the input file and writes the output to C<<STDOUT>>.

=head2 example

If you have a video file coming from a PAL source and a subtitle file indexed for a NTSC or a digital source, 
the subtitles will lag about half a second per minute. In this case, you should use the "-" parameter:

C<subspeed.pl film.srt - E<gt> film.new.srt>

=head2 note

This program will not correct fixed offsets, like for longer and shorter title sequences. Most media
players already offer the possibility to set such a fixed subtitle offset.

=head2 installation

On *nix style operation systems, install the program with

C<sudo cp subspeed.pl /usr/local/bin; sudo chmod a+x /usr/local/bin/subspeed.pl> 

=cut

use feature 'say';
@ARGV or die "No parameters given! " .
  "Usage: subspeed.pl filename [+|-] > outfile.srt\n";
my ($filename, $speed) = @ARGV;
die "no such file: $filename\n" unless -e $filename;
die "no valid speed parameter given! Usage: subspeed.pl filename [+|-] > ".
  "outfile.srt\n" unless $speed =~ /\+|-/; 
my $speedFunc = $speed =~ /\+/ ? sub { 
  return 25/24 * $_[0] 
} : sub { 
  return 24/25 * $_[0] 
};

open(my $fh, '<', $filename);
while(<$fh>) {
    unless(m/^\s*(\d+:\d\d:\d\d,\d+)\s+--\>\s+(\d+:\d\d:\d\d,\d+)\s+$/) {
        print;
        next
    }
    say join(' --> ',
      ( map { ms2ts($_) } ( map { 
         &$speedFunc($_) } ( map { 
           ts2ms($_) } ($1, $2) ) ) ) );
}
close($fh);

sub ts2ms { 
    my $ts = shift;
    $ts =~ s/^\s+//;
    $ts =~ s/\s+$//;
    my ($h, $m, $s) = split(':',$ts);
    my ($sec, $ms) = split(',',$s);
    $ms += 1000 * ( $sec + 60 * ( $m + 60 * $h));    
    return $ms
}

sub ms2ts {
    my $t = shift;
    $t = int($t);
    my $ms = $t % 1000;
    $ms = '0' . $ms if $ms < 100;
    $ms = '0' . $ms if $ms < 10;
    $t = int($t/1000);
    my $s = $t % 60;
    $t = int($t/60);
    my $m = $t % 60;
    my $h = int($t/60);
    $ms = '0' x ( 3 - length($ms) ) . $ms;
    s/^(\d)$/0$1/ foreach $h, $m, $s;
    return "$h:$m:$s,$ms"
}

