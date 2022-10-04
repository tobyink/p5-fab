package Fab::Step::Echo;

use Fab::Mite -all;
use Fab::Features;

extends 'Fab::Step';

param args => (
	isa         => 'ArrayRef',
	default     => [],
);

sub execute ( $self, $context ) {
	
	$context->log( info => $self->_process_args( $context ) );
	
	return;
}

sub _process_args ( $self, $context ) {
	return map( $self->_process_arg( $_, $context ), $self->args->@* );
}

sub _process_arg ( $self, $arg, $context ) {
	if ( blessed $arg and $arg->isa( 'Fab::BlueprintMaker::Stash' ) ) {
		return $arg->resolve( $context->stash );
	}
	if ( blessed $arg and $arg->isa( 'Path::Tiny' ) ) {
		return $arg->stringify;
	}
	return $arg;
}

1;
