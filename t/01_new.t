use strict;
use warnings;
use Test::More;
use Test::Fatal qw(exception lives_ok);
use Algorithm::HyperLogLog;
 
my $hll = Algorithm::HyperLogLog->new(5);
 
isa_ok $hll, 'Algorithm::HyperLogLog';
 
like exception{ Algorithm::HyperLogLog->new(3); }, qr/^Number of ragisters must be in the range/;
like exception{ Algorithm::HyperLogLog->new(17); }, qr/^Number of ragisters must be in the range/;
lives_ok{ Algorithm::HyperLogLog->new(4); };
lives_ok{ Algorithm::HyperLogLog->new(16); };
 
done_testing();
 
__END__

