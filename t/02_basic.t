use strict;
use warnings;
use Test::More;
use Test::Fatal qw(exception lives_ok);
use Algorithm::HyperLogLog;
 
my $hll = Algorithm::HyperLogLog->new(6);
 
my %unique;
 
for(0..99999){
    my $str = random_string(5);
    $unique{$str} = 1;
    $hll->add($str);
}
 
warn $hll->cardinality;
warn scalar(keys %unique);
 
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

