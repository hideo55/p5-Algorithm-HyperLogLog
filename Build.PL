use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Algorithm::HyperLogLog',
    license             => 'perl',
    dist_author         => 'Hideaki Ohno <hide.o.j55 {at} gmail.com>',
    dist_version_from   => 'lib/Algorithm/HyperLogLog.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'Algorithm-HyperLogLog-*' ],
);

$builder->create_build_script();
