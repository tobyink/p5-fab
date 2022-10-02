package Fab::Exception::TaskFailed;

use Fab::Mite -all;
use Fab::Features;

use overload q[""] => 'to_string', fallback => 1;

with 'Fab::Exception';

param task => (
	is          => ro,
	required    => true,
);

sub _build_message ( $self ) {
	return sprintf(
		'Task "%s"%s failed',
		$self->task->name,
		$self->context_to_string( $self->task->definition_context ),
	);
}

1;
