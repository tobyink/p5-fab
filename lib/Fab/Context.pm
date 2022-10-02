package Fab::Context;

use Fab::Mite -all;
use Fab::Features;

use Term::ANSIColor qw( colored );

param blueprint => (
	required    => true,
	isa         => 'Object',
);

field stash => (
	isa         => 'HashRef',
	default     => {},
);

field _already_fabricated => (
	isa         => 'HashRef',
	default     => {},
	handles_via => 'Hash',
	handles     => {
		set_already_fabricated => 'set',
		get_already_fabricated => 'get',
	},
);

field stack => (
	isa         => 'ArrayRef',
	default     => [],
	handles_via => 'Array',
	handles     => {
		_push_stack => 'push',
		_pop_stack  => 'pop',
		get_stack   => 'all',
		empty_stack => 'is_empty',
	},
);

sub default_task_names ( $self ) {
	return qw( .TOP );
}

sub fabricate ( $self, @task_names ) {
	
	if ( not @task_names ) {
		@task_names = $self->default_task_names;
	}
	
	try {
		for my $task_name ( @task_names ) {
			my @tasks = $self->blueprint->find_tasks( $task_name );
			for my $task ( @tasks ) {
				my $guard = $self->blueprint->_set_context( $self );
				$self->_push_stack( $task );
				$task->fabricate( $self );
				$self->_pop_stack;
			}
		}
		if ( $self->empty_stack ) {
			$self->log( success => 'Finished' );
		}
	}
	catch ( $e ) {
		if ( blessed $e and $e->DOES('Fab::Exception') ) {
			$self->log( error => "$e\nSTOPPED" );
		}
		else {
			die( $e );
		}
	};
}

sub log ( $self, $category, $message, @args ) {
	state $theme = {
		error    => [ 'black on_bright_red' ],
		warning  => [ 'bright_red' ],
		info     => [ 'bright_cyan' ],
		debug    => [ 'yellow' ],
		success  => [ 'bright_green' ],
	};
	if ( @args ) {
		$message = sprintf( $message, @args );
	}
	STDERR->print(
		colored(
			$theme->{$category} || croak('Unknown category'),
			$message
		) . "\n"
	);
}

1;
