package Fab::DSL;

use Fab::Features;
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
	go
);

sub definition_context {
	my %context;
	@context{qw( package file line )} = caller( 1 );
	\%context;
}

sub _exporter_validate_opts ( $class, $globals ) {
	require Fab::BlueprintMaker;
	$globals->{maker_class} = 'Fab::BlueprintMaker';
	our $MAKER = ( $globals->{maker} ||= $globals->{maker_class}->new( definition_context => definition_context() ) );
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

sub _generate_go ( $class, $name, $args, $globals ) {
	my $maker = $globals->{maker};
	return sub :prototype() {
		return $maker->go();
	};
}

1;
