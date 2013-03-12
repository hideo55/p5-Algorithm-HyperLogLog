use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Algorithm::HyperLogLog',
    AUTHOR        => 'Hideaki Ohno <hide.o.j55 {at} gmail.com>>',
    VERSION_FROM  => 'lib/Algorithm/HyperLogLog.pm',
    ABSTRACT_FROM => 'lib/Algorithm/HyperLogLog.pm',
    PL_FILES      => {},
    PREREQ_PM     => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'Algorithm-HyperLogLog-*' },
);

