package Alien::ChromeDriver;
use 5.008_001;
use strict;
use warnings;
use File::ShareDir qw(dist_file);

our $VERSION = '0.01';
our $VERBOSE = 1;

sub start {
    my $args = shift || '';
    my $binfile = find_bin_location();
 
    my $cmd = "$binfile $args";

    print "Running $cmd\n" if $VERBOSE;
    my $ret = system($cmd);
    die "Failed to run '$cmd': $!" if $ret == -1;
    print "chromedriver server has finished\n" if $VERBOSE;
}

sub find_bin_location {
    my $src_location = dist_file('Alien-ChromeDriver', 'chromedriver');

    if ($^O eq 'cygwin') {
        $src_location = `cygpath -m '$src_location'`;
        chomp $src_location;
    }

    die "Can't find $src_location!" unless -e $src_location;
    return $src_location;
}

1;
