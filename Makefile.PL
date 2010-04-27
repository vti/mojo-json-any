#!/usr/bin/env perl

use 5.008001;

use strict;
use warnings;

use ExtUtils::MakeMaker;

my $mm = $ExtUtils::MakeMaker::VERSION;

WriteMakefile(
    NAME         => 'Mojo::JSON::Any',
    VERSION_FROM => 'lib/Mojo/JSON/Any.pm',
    ABSTRACT     => "Use JSON::XS when it's available",
    AUTHOR       => 'Viacheslav Tykhanovskyi <vti@cpan.org>',

    ($mm < 6.3002 ? () : ('LICENSE' => 'artistic_2')),

    (   $mm < 6.46
        ? ()
        : ( META_MERGE => {
                requires => {perl => '5.008001'},
                resources =>
                  {repository => 'http://github.com/vti/mojo-json-any'},
                no_index => {directory => [qw/t/]}
            },
            META_ADD => {
                build_requires     => {},
                configure_requires => {}
            },
        )
    ),

    PREREQ_PM => {},
    test      => {TESTS => 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t'}
);
