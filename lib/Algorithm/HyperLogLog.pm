package Algorithm::HyperLogLog;
use strict;
use warnings;
use 5.008003;
use XSLoader;

our $VERSION = '0.03';

our $PERL_ONLY;
if ( !defined $PERL_ONLY ) {
    $PERL_ONLY = $ENV{PERL_HLL_PUREPERL} ? 1 : 0;
}

if ( !exists $INC{'Algorithm/HyperLogLog/PP.pm'} ) {
    if ( !$PERL_ONLY ) {
        $PERL_ONLY = !eval {
            XSLoader::load __PACKAGE__, $VERSION;
        };
    }
    if ( $PERL_ONLY ) {
        require 'Algorithm/HyperLogLog/PP.pm';
    }
}

sub XS {
    !$PERL_ONLY;
}

1;
__END__

=pod

=encoding utf8

=head1 NAME

Algorithm::HyperLogLog - Implementation of the HyperLogLog cardinality estimation algorithm

=head1 SYNOPSIS

  use Algorithm::HyperLogLog;
  
  my $hll = Algorithm::HyperLogLog->new(14);
  
  while(<>){
      $hll->add($_);
  }
  
  my $cardinality = $hll->estimate();


=head1 DESCRIPTION

This module is implementation of the HyperLogLog algorithm.

HyperLogLog is an algorithm for estimating the cardinality of a set.

=head1 METHODS

=head2 new($b)

Constructor.

`$b` is the parameter for determining register size. (The register size is 2^$b.)

`$b` must be a integer between 4 and 16.

=head2 add($data)

Adds element to the cardinality estimator.

=head2 estimate()

Returns estimated cardinality value in floation point number.

=head2 XS()

If using XS backend, this method return true value.

=head1 SEE ALSO

Philippe Flajolet, Éric Fusy, Olivier Gandouet and Frédéric Meunier. HyperLogLog: the analysis of a near-optimal cardinality estimation algorithm. 2007 Conference on Analysis of Algorithms, DMTCS proc. AH, pp. 127–146, 2007. L<http://algo.inria.fr/flajolet/Publications/FlFuGaMe07.pdf>

=head1 AUTHOR

Hideaki Ohno E<lt>hide.o.j55 {at} gmail.comE<gt>

=head1 THANKS TO

MurmurHash3(L<https://github.com/PeterScott/murmur3>)

=over 4

=item Austin Appleby

=item Peter Scott

=back

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
