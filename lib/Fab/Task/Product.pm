package Fab::Task::Product;

use Fab::Mite -all;
use Fab::Features;

extends 'Fab::Task';

sub this ( $self ) {
	return path( $self->name );
}

1;
