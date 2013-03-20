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

ok !$hll->XS, 'is Pure Perl?';

done_testing();

1;
__END__
