package Fab::Step;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

use Fab::Mite -all;
use Fab::Features;

param definition_context => (
	is          => rw,
	isa         => 'HashRef|Undef',
	required    => false,
);

param task => (
	is          => ro,
	isa         => 'Undef|Fab::Task',
	required    => true,
	weak_ref    => true,
);

1;
