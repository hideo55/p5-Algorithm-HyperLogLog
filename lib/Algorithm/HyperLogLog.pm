package Algorithm::HyperLogLog;
use strict;
use warnings;
use 5.008003;
use XSLoader;

our $VERSION = '0.01';

our $PERL_ONLY;
if ( !defined $PERL_ONLY ) {
    $PERL_ONLY = $ENV{PERL_HLL_PUREPERL} ? 1 : 0;
}
my $xs = 0;
if ( !exists $INC{'Algorithm/HyperLogLog/PP.pm'} ) {
    if ( !$PERL_ONLY ) {
        eval {
            XSLoader::load __PACKAGE__, $VERSION;
            $xs = 1;
        };
    }
    if ( !__PACKAGE__->can('new') ) {
        require 'Algorithm/HyperLogLog/PP.pm';
    }
}

sub XS {
    $xs;
}

1;
__END__

=pod

=head1 NAME

Algorithm::HyperLogLog - Implementation of the HyperLogLog algorithm

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new(register_size)

=head2 add($data)

=head2 estimate()

=head2 XS()

=head1 AUTHOR

Hideaki Ohno E<lt>hide.o.j55 {at} gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
