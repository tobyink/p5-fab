package Fab::Exception::PrerequisiteFailed;

use Fab::Mite -all;
use Fab::Features;

use overload q[""] => 'to_string', fallback => 1;

with 'Fab::Exception';

param task => (
	is          => ro,
	required    => true,
);

param prerequisite => (
	is          => ro,
	required    => true,
);

sub _build_message ( $self ) {
	return sprintf(
		'Task "%s"%s did not have prerequisite "%s"',
		$self->task->name,
		$self->context_to_string( $self->task->definition_context ),
		$self->prerequisite->name,
	);
}

1;
