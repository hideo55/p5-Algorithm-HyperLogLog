package Algorithm::HyperLogLog;
use strict;
use warnings;
use XSLoader;
 
BEGIN{
    our $VERSION = '0.01';
    XSLoader::load __PACKAGE__, $VERSION;
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

=head1 AUTHOR

Hideaki Ohno E<lt>hide.o.j55 {at} gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
