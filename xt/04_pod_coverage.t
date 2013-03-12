use strict;
use Test::More;
eval "use Test::Pod::Coverage";
plan skip_all => "Test::Pod::Coverage required for testing POD coverage" if $@;

for my $pkg ( all_modules() )
{
    pod_coverage_ok($pkg);
}

done_testing;
