#!perl
use strict;
use warnings;

use Alien::ChromeDriver;

Alien::ChromeDriver::start("@ARGV"); # flatten the arg list
