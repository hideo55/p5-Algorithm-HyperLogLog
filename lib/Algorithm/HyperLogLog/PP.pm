package Algorithm::HyperLogLog::PP;
use strict;
use warnings;
use 5.008003;
use Carp qw(croak);
use constant {
    HLL_HASH_SEED => 313,
    TWO_32        => 4294967296.0,
    NEG_TWO_32    => -4294967296.0,
};

require Algorithm::HyperLogLog;

{

    package Algorithm::HyperLogLog;
    our @ISA = qw(Algorithm::HyperLogLog::PP);
}

sub new {
    my ( $class, $k ) = @_;

    if ( $k < 4 || $k > 16 ) {
        croak "Number of ragisters must be in the range [4,16]";
    }

    my $m         = 1 << $k;
    my $registers = [ (0) x $m ];
    my $alpha     = 0;
    if ( $m == 16 ) {
        $alpha = 0.673;
    }
    elsif ( $m == 32 ) {
        $alpha = 0.697;
    }
    elsif ( $m == 64 ) {
        $alpha = 0.709;
    }
    else {
        $alpha = 0.7213 / ( 1.0 + 1.079 / $m );
    }

    my $self = {
        k         => $k,
        m         => $m,
        registers => $registers,
        alphaMM   => $alpha * $m * $m,
    };
    bless $self, $class;
    return $self;
}

sub add {
    my ( $self, $data ) = @_;
    my $hash = _murmur32( $data, HLL_HASH_SEED );
    my $index = ( $hash >> ( 32 - $self->{'k'} ) );
    my $rank = _rho( ( $hash << $self->{k} ), 32 - $self->{k} );
    if ( $rank > $self->{registers}[$index] ) {
        $self->{registers}[$index] = $rank;
    }
}

sub estimate {
    my $self = shift;
    my $m    = $self->{m};

    my $rank = 0;
    my $sum  = 0.0;
    for my $i ( 0 .. ( $m - 1 ) ) {
        $rank = $self->{registers}[$i];
        $sum += 1.0 / ( 2.0**$rank );
    }

    my $estimate = $self->{alphaMM} * ( 1.0 / $sum );    # E in the original paper
    if ( $estimate <= 2.5 * $m ) {
        my $v = 0;
        for my $i ( 0 .. ( $m - 1 ) ) {
            if ( $self->{registers}[$i] == 0 ) {
                $v++;
            }
        }

        if ( $v != 0 ) {
            $estimate = $m * log( $m / $v );
        }
    }
    elsif ( $estimate > ( 1.0 / 30.0 ) * TWO_32 ) {
        $estimate = NEG_TWO_32 * log( 1.0 - ( $estimate / TWO_32 ) );
    }
    return $estimate;
}

sub XS {
    0;
}

sub _rotl32 {
    my ( $x, $r ) = @_;
    return ( ( $x << $r ) | ( $x >> ( 32 - $r ) ) );
}

sub _fmix32 {
    my $h = shift;
    $h = ($h ^ ( $h >> 16 ));
    {
	    use integer;
    	$h = _to_uint( ( $h * 0x85ebca6b ) & 0xffffffff );
	}
    $h = ( $h ^ ( $h >> 13 ) );
	{
		use integer;
    	$h = _to_uint( ( $h * 0xc2b2ae35 ) & 0xffffffff );
	}
    $h = ( $h ^ ( $h >> 16 ) );
    return $h;
}

sub _mmix32 {
    my $k1 = shift;
	use integer;
    $k1 = _to_uint( ( $k1 * 0xcc9e2d51 ) & 0xffffffff );
    $k1 = _rotl32( $k1, 15 );
    return _to_uint(( $k1 * 0x1b873593 ) & 0xffffffff);
}

sub _murmur32 {
    my ( $key, $seed ) = @_;
	if( !defined $seed ){
	    $seed = 0;
	}
    utf8::encode($key);
    my $len        = length($key);
    my $num_blocks = int( $len / 4 );
    my $tail_len   = $len % 4;
    my @vals       = unpack( 'V*C*', $key );
    my @tail       = splice( @vals, scalar(@vals) - $tail_len, $tail_len );
    my $h1         = $seed;

    for my $block (@vals) {
        my $k1 = $block;
        $h1 ^= _mmix32($k1);
        $h1 = _rotl32( $h1, 13 );
		use integer;
        $h1 = _to_uint(( $h1 * 5 + 0xe6546b64 ) & 0xffffffff);
    }

    if ( @tail > 0 ) {
        my $k1 = 0;
        for my $c1 ( reverse @tail ) {
            $k1 = ( ( $k1 << 8 ) | $c1 );
        }
		$k1 = _mmix32($k1);
        $h1 = ( $h1 ^ $k1 );
    }
	$h1 =  ($h1 ^ $len);
	$h1 =  _fmix32($h1);
    return $h1;
}

sub _rho {
    my ( $x, $b ) = @_;
    my $v = 1;
    while ( $v <= $b && !( $x & 0x80000000 ) ) {
        $v++;
        $x <<= 1;
    }
    return $v;
}

sub _to_uint {
	no integer;
	return 0 || $_[0];
}

1;
__END__
