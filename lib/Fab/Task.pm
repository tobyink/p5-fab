package Fab::Task;

use Fab::Mite -all;
use Fab::Features;

use Fab::Exception::TaskFailed;
use Fab::Exception::PrerequisiteFailed;

param definition_context => (
	is          => rw,
	isa         => 'HashRef|Undef',
	required    => false,
);

param blueprint => (
	is          => ro,
	isa         => 'Fab::Blueprint',
	required    => true,
	weak_ref    => true,
);

param name => (
	is          => ro,
	required    => true,
);

field id => (
	isa         => 'Int',
	builder     => sub ( $self ) { state $id = 0; ++$id },
);

field steps => (
	isa         => 'ArrayRef[Fab::Step]',
	default     => [],
	handles_via => 'Array',
	handles     => {
		_push_step => 'push',
		all_steps  => 'all',
	},
);

field requirements => (
	isa         => 'ArrayRef',
	default     => [],
	handles_via => 'Array',
	handles     => {
		_push_requirement => 'push',
		all_requirements  => 'all',
	},
);

sub add_step ( $self, $step ) {
	$self->_push_step( $step );
}

sub add_requirement ( $self, $r ) {
	$self->_push_requirement( $r );
}

sub this ( $self ) {
	croak "This task doesn't support this()";
}

sub fabricate ( $self, $context ) {
	if ( $self->already_fabricated( $context ) ) {
		$context->set_already_fabricated( $self->id, true );
		return;
	}
	
	# In progress, but mark as already fabricated to avoid cycles
	$context->set_already_fabricated( $self->id, true );
	
	$context->log( info => 'Task: "%s"', $self->name );
	
	try {
		for my $r ( $self->all_requirements ) {
			$context->fabricate( $r );
		}
	}
	catch ( $e ) {
		if ( blessed( $e ) and $e->isa( 'Fab::Exception::TaskFailed' ) ) {
			'Fab::Exception::PrerequisiteFailed'->throw(
				task => $self,
				prerequisite => $e->task,
				original_exception => $e,
			);
		}
		else {
			$e->rethrow;
		}
	};
	
	try {
		for my $s ( $self->all_steps ) {
			$s->execute( $context );
		}
	}
	catch ( $e ) {
		if ( blessed( $e ) and $e->isa( 'Fab::Exception::StepFailed' ) ) {
			'Fab::Exception::TaskFailed'->throw(
				task => $self,
				original_exception => $e,
			);
		}
		else {
			$e->rethrow;
		}
	};
}

sub already_fabricated ( $self, $context ) {
	if ( $context->get_already_fabricated( $self->id ) ) {
		return true;
	}
	return false;
}

1;

