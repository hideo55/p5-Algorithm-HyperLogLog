use strict;
use warnings;
use Test::More;
use Test::Fatal qw(exception lives_ok);

BEGIN {
    $Algorithm::HyperLogLog::PERL_ONLY = 1;
}
use Algorithm::HyperLogLog;
my $hll = Algorithm::HyperLogLog->new(6);

isa_ok $hll, 'Algorithm::HyperLogLog';

ok !$hll->XS;

my $error_sum = 0;
my $repeat    = 100;

for ( 1 .. $repeat ) {

    my $hll = Algorithm::HyperLogLog->new(14);

    my %unique = ( q{} => 1 );

    for ( 0 .. 999 ) {
        my $str = q{};
        while ( exists $unique{$str} ) {
            $str = random_string(10);
        }
        $unique{$str} = 1;
        $hll->add($str);
    }

    $unique{'foo'} = 1;
    for ( 0 .. 999 ) {
        $hll->add('foo');
    }

    $unique{'bar'} = 1;
    for ( 0 .. 999 ) {
        $hll->add('bar');
    }

    my $cardinality = $hll->estimate;

    my $unique = scalar keys %unique;

    $error_sum += abs( $unique - $cardinality );

}

my $error_avg   = $error_sum / $repeat;
my $error_ratio = $error_avg / 10001 * 100;

if( $error_ratio < 1.0 ){
    ok(1);
}else{
    diag $error_ratio;
    fail(1);
}

done_testing();

sub random_string {
    my $n   = shift;
    my $str = q{};
    for ( 1 .. $n ) {
        my $rand = rand(26);
        $str .= chr( ord('A') + $rand );
    }
    return $str;
}

1;
__END__
