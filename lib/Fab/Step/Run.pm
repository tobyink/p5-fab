package Fab::Step::Run;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

use Fab::Mite -all;
use Fab::Features;

extends 'Fab::Step';

use Fab::Exception::StepFailed ();
use IPC::Run ();

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
		return $self->_execute_coderef( $context, $command, \@args );
	}
	else {
		return $self->_execute_binary( $context, $command, \@args );
	}
}

sub _process_args ( $self, $context ) {
	return map( $self->_process_arg( $_, $context ), $self->args->@* );
}

sub _process_arg ( $self, $arg, $context ) {
	if ( blessed $arg and $arg->isa( 'Fab::BlueprintMaker::Stash' ) ) {
		return $arg->resolve( $context->stash );
	}
	if ( blessed $arg and $arg->isa( 'Path::Tiny' ) and ref($self->command) ne 'CODE' ) {
		return $arg->stringify;
	}
	return $arg;
}

sub _execute_coderef ( $self, $context, $command, $args ) {
	
	try {
		local $Fab::CONTEXT = $context;
		local $Fab::STEP    = $self;
		$command->( $args->@* );
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
	
sub _execute_binary ( $self, $context, $command, $args ) {
	
	if ( blessed $command and $command->isa( 'Path::Tiny' ) ) {
		$command = $command->stringify;
	}
	
	my $in  = $context->get_setting( 'stdin'  ) // \*STDIN;
	my $out = $context->get_setting( 'stdout' ) // \*STDOUT;
	my $err = $context->get_setting( 'stderr' ) // \*STDERR;
	
	my $ok  = IPC::Run::run(
		$args->@*
			? [ $command, $args->@* ]
			: [ qw( sh -c ), $command ], # XXX: windows
		'<'  => $in,
		'>'  => $out,
		'2>' => $err,
	);
	
	if ( not $ok ) {
		'Fab::Exception::StepFailed'->throw(
			error => "process failed",
			step  => $self,
		);
	}
	
	return;
}

1;
