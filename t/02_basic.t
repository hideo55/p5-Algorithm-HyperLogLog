use strict;
use warnings;
use Test::More;
use Test::Fatal qw(exception lives_ok);
use Algorithm::HyperLogLog;
 
my $hll = Algorithm::HyperLogLog->new(7);
 
my %unique = ( q{} => 1 );
 
for(0..99999){
    my $str = q{};
    while( exists $unique{$str} ){
        $str = random_string(10);
    }
    $unique{$str} = 1;
    $hll->add($str);
}

$unique{'foo'} = 1;
for(0..999999){
    $hll->add('foo');
}

$unique{'bar'} = 1;
for(0..999999){
    $hll->add('bar');
}

 
warn $hll->estimate;
warn scalar(keys %unique) -1;
 
ok(1);
 
done_testing();
 
 
sub random_string{
    my $n = shift;
    my $str = q{};
    for(1..$n){
        my $rand = rand(26);
        $str .= chr(ord('A') + $rand);
    }
    return $str;
}
 
__END__

