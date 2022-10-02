package Fab::BlueprintMaker;

use Fab::Mite -all;
use Fab::Features;

param definition_context => (
	is          => rw,
	isa         => 'HashRef|Undef',
	required    => false,
);

field blueprint => (
	isa         => 'Fab::Blueprint',
	builder     => sub ( $self ) {
		require Fab::Blueprint;
		'Fab::Blueprint'->new;
	},
);

field _current_task => (
	is          => rw,
	isa         => 'Fab::Task',
	clearer     => true,
);

sub product ( $self, $name, %args ) {
	require Fab::Task::Product;
	my $as = delete $args{as};
	my $product = 'Fab::Task::Product'->new(
		name      => $name,
		blueprint => $self->blueprint,
		%args,
	);
	$self->_current_task( $product );
	$as->() if $as;
	$self->_clear__current_task;
	$self->blueprint->add_task( $product );
	return $product;
}

sub task ( $self, $name, %args ) {
	require Fab::Task::Simple;
	my $as = delete $args{as};
	my $task = 'Fab::Task::Simple'->new(
		name      => $name,
		blueprint => $self->blueprint,
		%args,
	);
	$self->_current_task( $task );
	$as->() if $as;
	$self->_clear__current_task;
	$self->blueprint->add_task( $task );
	return $task;
}

sub need ( $self, @args ) {
	$self->_current_task->add_requirement( $_ ) for @args;
	return;
}

sub run ( $self, $cmd, @args ) {
	require Fab::Step::Run;
	my $run = 'Fab::Step::Run'->new(
		command  => $cmd,
		args     => \@args,
		task     => $self->_current_task,
	);
	if ( $self->_current_task ) {
		$self->_current_task->add_step( $run );
	}
	elsif ( $self->blueprint->finalized ) {
		$run->execute( $self->blueprint->context );
	}
	else {
		croak 'Cannot run() here';
	}
	return $run;
}

sub this ( $self ) {
	my $task = $self->_current_task;
	return $task->this();
}

sub stash ( $self ) {
	my $blueprint = $self->blueprint;
	return $blueprint->stash if $blueprint->finalized;
	require Fab::BlueprintMaker::Stash;
	return 'Fab::BlueprintMaker::Stash'->new( '$STASH' );
}

sub go ( $self ) {
	return if our $NO_GO;
	my $blueprint = $self->blueprint;
	$blueprint->finalize();
	require Fab::Context;
	my $context = 'Fab::Context'->new( blueprint => $blueprint );
	$context->fabricate();
	return;
}

1;
