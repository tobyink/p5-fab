package Fab::Step::Set;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

use Fab::Mite -all;
use Fab::Features;

extends 'Fab::Step';

param key => (
	required    => true,
	isa         => 'Str',
);

param value => (
	required    => true,
	isa         => 'Any',
);

sub execute ( $self, $context ) {
	
	$context->set_setting( $self->key, $self->value );
	return;
}

1;
