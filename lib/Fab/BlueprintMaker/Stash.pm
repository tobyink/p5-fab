package Fab::BlueprintMaker::Stash;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

use Fab::Features;
use B ();

sub resolve ( $self, $STASH ) {
	eval( $$self );
}

use overload (
	bool      => sub { !!1 },
	'@{}'     => '_overload_ARRAY',
	'%{}'     => '_overload_HASH',
);

sub new ( $class, $path ) {
	return bless( \$path, $class );
}

sub _overload_ARRAY ( $self, @ ) {
	my @array;
	tie( @array, 'Fab::BlueprintMaker::Stash::ARRAY', $self );
	return \@array;
}

sub _overload_HASH ( $self, @ ) {
	my %hash;
	tie( %hash, 'Fab::BlueprintMaker::Stash::HASH', $self );
	return \%hash;
}

package Fab::BlueprintMaker::Stash::HASH {
	our $AUTHORITY = 'cpan:TOBYINK';
	our $VERSION   = '0.000_001';
	sub TIEHASH ( $class, $object ) {
		return bless( \$object, $class );
	}
	sub FETCH ( $self, $key ) {
		my $path = sprintf( '%s->{%s}', $$$self, B::perlstring($key) );
		return 'Fab::BlueprintMaker::Stash'->new( $path );
	}
	$INC{'Fab/BlueprintMaker/Stash/HASH.pm'} = __FILE__;
}

package Fab::BlueprintMaker::Stash::ARRAY {
	our $AUTHORITY = 'cpan:TOBYINK';
	our $VERSION   = '0.000_001';
	sub TIEARRAY ( $class, $object ) {
		return bless( \$object, $class );
	}
	sub FETCH ( $self, $idx ) {
		my $path = sprintf( '%s->[%d]', $$$self, $idx );
		return 'Fab::BlueprintMaker::Stash'->new( $path );
	}
	$INC{'Fab/BlueprintMaker/Stash/ARRAY.pm'} = __FILE__;
}

1;
