#!/usr/bin/perl

use feature 'say';

our $maxBase = @ARGV && @ARGV[0] =~ /^\d+$/ ? shift : 64;

our $primeLimit = $maxBase * ($maxBase-1)/2; 

our @primes = ( 2 );
our @semiPrimes;
our @symbols = qw( 
    0 1 2 3 4 5 6 7 8 9
    A B C D E F G H I J
    K L M N O P Q R S T
    U V W X Y Z );
our $separator = ',';

# First get a list of the first $primeLimit primes

my $test = 3;
$test = nextPrime($test) until @primes >= $primeLimit;

makeSemiPrimes();


say "Smallest semi prime twins which are anagrams in different number systems"; 
for( my $base = 2; $base <= $maxBase; $base++ ) {
    say "\nBase $base symbols: ".( $base <= @symbols ? join('', (@symbols)[0..($base-1)]) : "b(0),...,b(".($base-1).")");
    my $n = 1;
    while($n && $n < @semiPrimes) {
        my @testSemis = ( $semiPrimes[$n-1], $semiPrimes[$n] );
        if(areAnagrams($base, $testSemis[0], $testSemis[1])) {
            say "\tdecimal notation: ".niceNumber($testSemis[0])."/".niceNumber($testSemis[1])." native notation: ".getBaseNotation($base,$testSemis[0]).'/'.getBaseNotation($base,$testSemis[1]);
            $n = -1;
        }
        $n++;
    }
    if($n) {
        say 'No numbers found! Perhaps you should increase $primeLimit.';
    }
}

sub makeSemiPrimes {
    for(my $i = 0; $i < $primeLimit; $i++) {
        for(my $j = $i; $j < $primeLimit; $j++) {
            push(@semiPrimes,$primes[$i]*$primes[$j]);
        }
    }
    @semiPrimes = sort { $a <=> $b } @semiPrimes
}

sub arraysEqual {
    my ($a1, $a2) = @_;
    return 0 unless @$a1 == @$a2;
    @$a1 = sort { $a <=> $b } @$a1;
    @$a2 = sort { $a <=> $b } @$a2;
    while(@$a1) {
        return 0 unless shift(@$a1) == shift(@$a2)
    }
    return 1;
}

sub getDigits {
    my ($base, $number) = @_;
    my @digits;
    while($number) {
        push(@digits,$number % $base);
        $number = int($number/$base);
    }
    @digits = ( 0 ) unless @digits;
    return @digits;
}

sub areAnagrams {
    my($base, $n1, $n2) = @_;
    my @d1 = getDigits($base,$n1);
    my @d2 = getDigits($base,$n2);
    return arraysEqual(\@d1,\@d2);
}

sub isPrime {
    my $n = shift;
    for(@primes) {
        return 1 if  $_*$_ > $n; 
        return 0 unless $n % $_;
    }
    return 1;
}

sub nextPrime {
    my $n = shift;
    $n = $n + 2 until isPrime($n);
    push(@primes, $n);
    return $n + 2;
}

sub getBaseNotation {
    my ($base, $n) = @_;
    my @digitSymbols = $base <= @symbols ? (@symbols)[0..($base-1)] : map { "b($_)" } (0..($base-1));
    return niceNumber(join('', reverse( map {$digitSymbols[$_]} getDigits($base, $n) ) ));
}

sub niceNumber {
    my $n = shift;
    if($n =~ /^(b\(\d+\))+$/) {
        my $s = 'b\(\d+\)';
        while($n =~ /^(($s)+)(($s){3})(($separator(($s){3}))*)$/) {
            $n = "$1$separator$3$5";
        }
    } else {
        while($n =~ /^([^$separator]+)([^$separator]{3})((,[^$separator]{3})*)$/) {
            $n = "$1$separator$2$3";
        }
    }
    return $n;
}

