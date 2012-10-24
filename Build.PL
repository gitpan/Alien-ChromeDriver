#!perl
use strict;
use warnings;

use Module::Build::Compat;
use inc::MyBuilder;

use Config;
use File::Copy qw(move);
use File::Path qw(mkpath);
use File::Spec::Functions qw(catfile);

use autodie;
use Web::Query qw(wq);
use LWP::Simple qw(mirror);

STDOUT->autoflush(1);

if (!grep { $_ eq '--no-upgrade' } @ARGV) {
    my $latest_version = do {
        my $filename = wq('http://code.google.com/p/chromedriver/downloads/list')->find('.ifOpened .col_0')->first->text;
        ($filename =~ /([0-9\.]+)\.zip/)[0];
    };

    print "chromedriver version $latest_version\n";

    my $download_link = sprintf(
        'http://chromedriver.googlecode.com/files/chromedriver_%s_%s.zip',
        (
            ($^O eq 'darwin')                        ? 'mac'
          : ($^O eq 'MSWin32')                       ? 'win'
          : ($^O eq 'linux' && $Config{use64bitint}) ? 'linux64'
          :                                            'linux32'
        ),
        $latest_version,
    );

    print "# donwloading $download_link\n";
    print "# => ", scalar mirror($download_link, "chromedriver.zip"), "\n";
}

print "# unpacking chromedriver.zip\n";
system('unzip',  "chromedriver.zip"); # TODO windows...
unlink('chromedriver.zip');
chmod(0755, 'chromedriver');

mkpath 'share';
File::Copy::move('chromedriver', catfile('share', 'chromedriver'));

print "writing Makefile\n";

my $builder = inc::MyBuilder->new(
    module_name => 'Alien::ChromeDriver',
    dist_author => 'Hiroki Honda (Cside) <cside.story(at)gmail.com>',
    dist_abstract => 'install chromedriver',
    license     => 'perl',

    requires    => {
        perl => 5.008_001,

        'File::ShareDir' => 0,
    },

    configure_requires => {
        'Module::Build' => 0,
        'LWP::Simple'   => 0,
        'Web::Query'    => 0,
        'autodie'       => 0,
    },

    build_requires => {
        'File::ShareDir' => 0,
    },

    test_requires => {
        'Test::More' => 0.88,
    },

    script_files => 'bin/chromedriver.pl',

    share_dir => 'share',

    dist_meta => 0, # to make `cpanm .` happy

    no_index => {
        directory =>  [
            'inc',
            'author',
        ],
    },

    add_to_cleanup => [
        'chromedriver',
        'Makefile',
        'blib',
        'share',
    ],
);

$builder->create_build_script();

# write Makefile for an easy interface to the build script
Module::Build::Compat->write_makefile(build_class => ref $builder);

