#!perl -w
use strict;
use Test::More tests => 1;

BEGIN {
    use_ok 'Alien::ChromeDriver';
}

diag "Testing Alien::ChromeDriver/$Alien::ChromeDriver::VERSION";
