package Fab::Task;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

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

sub expand_requirements ( $self, $context, $already={} ) {
	my @return;
	$already->{ $self->name } = 1;
	
	for my $r ( $self->all_requirements ) {
		my @found = $self->blueprint->find_tasks( $r );
		if ( @found ) {
			while ( @found ) {
				my $f = shift @found;
				if ( not $already->{ $f->name }++ ) {
					push @return, $f;
					push @found, $f->expand_requirements( $context, { $already->%* } );
				}
			}
		}
		else {
			if ( ( !ref($r) or ref($r) ne 'Regexp' ) and -e $r ) {
				# Task needs a file for which we have no task to create, but
				# the file already exists so create a do-nothing task to create
				# it.
				require Fab::Task::Product;
				push @return, 'Fab::Task::Product'->new(
					blueprint => $self->blueprint,
					name      => $r,
				);
			}
			else {
				$context->log(
					error => 'Task "%s" needs "%s" but it does not exist and there is no task to create it',
					$self->name, $r,
				);
			}
		}
	}
	
	return @return;
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
	$self->satisfy_prerequisites( $context );
	$self->run_steps( $context );
	$self->check_postrequisites( $context );
}

sub already_fabricated ( $self, $context ) {
	
	if ( $context->get_already_fabricated( $self->id ) ) {
		return true;
	}
	return false;
}

sub satisfy_prerequisites ( $self, $context ) {
	
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
	}
}

sub run_steps ( $self, $context ) {
	
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
	}
}

sub check_postrequisites ( $self, $context ) {
	return;
}

1;
