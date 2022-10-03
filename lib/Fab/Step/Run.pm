package Fab::Step::Run;

use Fab::Mite -all;
use Fab::Features;

extends 'Fab::Step';

use Fab::Exception::StepFailed ();

param command => (
	required    => true,
	isa         => 'Str|Path::Tiny|CodeRef',
);

param args => (
	isa         => 'ArrayRef',
	default     => [],
);

sub execute ( $self, $context ) {
	
	my $command = $self->command;
	my @args    = $self->_process_args( $context );
	
	$context->log(
		debug => 'Run: %s%s',
		$command,
		scalar(@args) ? sprintf( '( %s )', join( q{, }, @args ) ) : '',
	);
	
	if ( ref($command) eq 'CODE' ) {
		try {
			local $Fab::CONTEXT = $context;
			local $Fab::STEP    = $self;
			$command->( @args );
		}
		catch ( $e ) {
			'Fab::Exception::StepFailed'->throw(
				error => $e,
				step  => $self,
				original_exception => $e,
			);
		};
		return;
	}
	
	if ( blessed $command and $command->isa( 'Path::Tiny' ) ) {
		$command = $command->absolute->stringify;
	}
	
	# XXX: optionally capture STDOUT and STDERR
	my $result = system( $command, @args );
	$result >>= 8;
	
	if ( $result ) {
		'Fab::Exception::StepFailed'->throw(
			error => "process ended with code $result",
			step  => $self,
		);
	}
	
	return;
}

sub _process_args ( $self, $context ) {
	return map( $self->_process_arg( $_, $context ), $self->args->@* );
}

sub _process_arg ( $self, $arg, $context ) {
	if ( blessed $arg and $arg->isa( 'Fab::BlueprintMaker::Stash' ) ) {
		return $arg->resolve( $context->stash );
	}
	if ( blessed $arg and $arg->isa( 'Path::Tiny' ) and ref($self->command) ne 'CODE' ) {
		return $arg->absolute->stringify;
	}
	return $arg;
}

1;
