package Fab::Exception::PrerequisiteFailed;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

use Fab::Mite -all;
use Fab::Features;

use overload q[""] => 'to_string', fallback => 1;

extends 'Fab::Exception::TaskFailed';

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
