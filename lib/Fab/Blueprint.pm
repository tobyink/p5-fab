package Fab::Blueprint;

use Fab::Mite -all;
use Fab::Features;

param definition_context => (
	is          => rw,
	isa         => 'HashRef|Undef',
	required    => false,
);

field finalized => (
	is          => ro,
	isa         => 'Bool',
	default     => false,
	handles_via => 'Bool',
	handles     => { finalize => 'set' },
);

field tasks => (
	isa         => 'ArrayRef[Fab::Task]',
	default     => [],
	handles_via => 'Array',
	handles     => {
		_push_task => 'push',
		all_tasks  => 'all',
	},
);

field task_lookup => (
	isa        => 'HashRef',
	clearer    => 1,
	builder    => sub ( $self ) {
		return +{ map +( $_->name => $_ ), $self->all_tasks };
	},
);

field context => (
	is          => ro,
	isa         => 'Object',
	local_writer=> '_set_context',
	handles     => [ 'stash' ],
);

sub add_task ( $self, $task ) {
	croak 'Cannot add task to finalized blueprint' if $self->finalized;
	$self->clear_task_lookup;
	$self->_push_task( $task );
}

sub find_tasks ( $self, $search ) {
	if ( my $task = $self->task_lookup->{$search} ) {
		return ( $task );
	}
	if ( ref($search) ne 'Regexp' ) {
		require Text::Glob;
		$search = Text::Glob::glob_to_regex( "$search" );
	}
	return grep( $_->name =~ /$search/, $self->all_tasks );
}

1;
