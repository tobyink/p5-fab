package Fab::Exception::StepFailed;

use Fab::Mite -all;
use Fab::Features;

use overload q[""] => 'to_string', fallback => 1;

with 'Fab::Exception';

param error => (
	is          => ro,
	required    => true,
);

param step => (
	is          => ro,
	required    => true,
);

sub _build_message ( $self ) {
	return sprintf(
		'Step%s failed: %s',
		$self->context_to_string( $self->step->definition_context ),
		$self->error,
	);
}

1;
