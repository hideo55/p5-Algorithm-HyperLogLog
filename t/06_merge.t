use strict;
use warnings;
use Test::More;
use Test::Fatal qw(exception lives_ok);
use Algorithm::HyperLogLog;

plan 'skip_all' => 'No XS' if !Algorithm::HyperLogLog->XS;

my $hlla   = Algorithm::HyperLogLog->new(16);
my $hllb   = Algorithm::HyperLogLog->new(16);

$hlla->add($_) for 1..100_000;
$hllb->add($_) for 100_000..200_000;

$hlla->merge($hllb);

ok( abs($hlla->estimate -200_000)/200_000 < 0.01);

done_testing();

__END__

