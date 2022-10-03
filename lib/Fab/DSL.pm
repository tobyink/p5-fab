package Fab::DSL;

use Fab::Features;
use Hook::AfterRuntime qw( after_runtime );
use parent 'Exporter::Tiny';

our @EXPORT = qw(
	product
	task
	as
	need
	run
	set
	this
	stash
	echo
);

sub definition_context ( $level = 1 ) {
	my %context;
	@context{qw( package file line )} = caller( $level );
	\%context;
}

sub _exporter_validate_opts ( $class, $globals ) {
	require Fab::BlueprintMaker;
	$globals->{maker_class} = 'Fab::BlueprintMaker';
	$Fab::MAKER = ( $globals->{maker} ||= $globals->{maker_class}->new(
		definition_context => definition_context(5),
	) );
	
	after_runtime { $globals->{maker}->go }; 
}

sub _generate_product ( $class, $name, $args, $globals ) {
	my $maker = $globals->{maker};
	return sub ( $name, %args ) {
		$maker->product( $name, %args, definition_context => definition_context() );
		return;
	};
}

sub _generate_task ( $class, $name, $args, $globals ) {
	my $maker = $globals->{maker};
	return sub ( $name, %args ) {
		$maker->task( $name, %args, definition_context => definition_context() );
		return;
	};
}

sub as :prototype(&) ( $code ) {
	return as => $code;
}

sub _generate_need ( $class, $name, $args, $globals ) {
	my $maker = $globals->{maker};
	return sub ( @args ) {
		$maker->need( @args );
		return;
	};
}

sub _generate_run ( $class, $name, $args, $globals ) {
	my $maker = $globals->{maker};
	return sub ( @args ) {
		my $step = $maker->run( @args );
		$step->definition_context( definition_context() );
		return;
	};
}

sub _generate_set ( $class, $name, $args, $globals ) {
	my $maker = $globals->{maker};
	return sub ( $key, $val ) {
		my $step = $maker->set( $key, $val );
		$step->definition_context( definition_context() );
		return;
	};
}

sub _generate_echo ( $class, $name, $args, $globals ) {
	my $maker = $globals->{maker};
	return sub ( @args ) {
		my $step = $maker->echo( @args );
		$step->definition_context( definition_context() );
		return;
	};
}

sub _generate_this ( $class, $name, $args, $globals ) {
	my $maker = $globals->{maker};
	return sub :prototype() {
		return $maker->this();
	};
}

sub _generate_stash ( $class, $name, $args, $globals ) {
	my $maker = $globals->{maker};
	return sub :prototype() {
		return $maker->stash();
	};
}

1;
