use strict;
use warnings FATAL => 'all';
use Module::Build;
 
my $class = Module::Build->subclass(
    code => <<'__CODE__',
    use Devel::PPPort;
 
    sub ACTION_build {
        my $self = shift;
        $self->depends_on('ppport_h');
        $self->SUPER::ACTION_build;
    }
 
    sub ACTION_ppport_h {
        my $self = shift;
        my $filepath = './lib/Algorithm/ppport.h';
        unless (-e $filepath) {
            print "Writing $filepath\n";
            Devel::PPPort::WriteFile($filepath);
        }
        $self->add_to_cleanup($filepath);
    }
 
__CODE__
);
 
my $builder = $class->new(
    module_name        => 'Algorithm::HyperLogLog',
    dist_author        => 'Hideaki Ohno<hide.o.j55@gmail.com>',
    license            => 'perl',
    configure_requires => { 'Module::Build' => '0.38' },
    build_requires     => {
        'Test::More'  => '0.98',
        'Test::Fatal' => '0.008',
    },
    requires => {
        'XSLoader' => 0,
    },
    needs_compiler => 1,
    c_source => 'src',
    xs_files => {
        './src/hyperloglog.xs' => './lib/Algorithm/HyperLogLog.xs',
    },
    no_index => { 'directory' => [ 't', 'xt', 'inc', 'eg' ] },
    test_files => ( -d '.git' || $ENV{RELEASE_TESTING} ) ? [qw(t/ xt/)] : ['t/'],
    create_readme      => 1,
    add_to_cleanup     => ['Algorithm-HyperLogLog-*'],
    meta_merge         => {
        keywords  => [qw/HyperLogLog cardinality/],
        resources => {
            repository => 'git://github.com/hideo55/Data-Iterator-SlidingWindow.git',
            bugtracker => 'https://github.com/hideo55/Data-Iterator-SlidingWindow/issues',
        },
    },
);
 
$builder->create_build_script();
