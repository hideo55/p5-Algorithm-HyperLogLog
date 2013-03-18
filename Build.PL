use strict;
use warnings FATAL => 'all';
use Module::Build::Pluggable (
    'CPANfile',
    'GithubMeta',
    'XSUtil' => {
        cc_warnings => 1,
        ppport      => 'lib/Algorithm/ppport.h',
    },
);

my $builder = Module::Build::Pluggable->new(
    module_name    => 'Algorithm::HyperLogLog',
    dist_author    => 'Hideaki Ohno<hide.o.j55@gmail.com>',
    license        => 'perl',
    needs_compiler => 1,
    c_source       => 'src',
    xs_files       => { './src/hyperloglog.xs' => './lib/Algorithm/HyperLogLog.xs', },
    no_index       => { 'directory' => [ 't', 'xt', 'inc', 'eg' ] },
    test_files => ( -d '.git' || $ENV{RELEASE_TESTING} ) ? [qw(t/ xt/)] : ['t/'],
    create_readme  => 1,
    add_to_cleanup => [
        'Algorithm-HyperLogLog-*', 'lib/Algorithm/typemap', 'MANIFEST.bak', 'lib/Algorithm/*.o',
        'lib/Algorithm/*.h',       'lib/Algorithm/*.c',     'lib/Algorithm/*.xs',
    ],
    meta_add => {
        keywords  => [qw/HyperLogLog cardinality/],
        resources => { bugtracker => 'https://github.com/hideo55/p5-Algorithm-HyperLogLog/issues', },
    },
);

$builder->create_build_script();
