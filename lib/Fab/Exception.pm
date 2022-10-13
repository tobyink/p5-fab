package Fab::Exception;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

use Fab::Mite -all, -role;
use Fab::Features;

param message => (
	is          => lazy,
	isa         => 'Str',
	builder     => true,
);

param original_exception => (
	is          => ro,
	predicate   => true,
	required    => false,
);

sub throw ( $class, @args ) {
	die( $class->new( @args ) );
}

sub to_string ( $self, @ ) {
	my $msg = $self->message . "\n";
	if ( $self->has_original_exception ) {
		$msg .= "\tbecause: " . (
			blessed($self->original_exception) && $self->original_exception->DOES( __PACKAGE__ )
				? $self->original_exception->to_string
				: "@{[ $self->original_exception ]}\n"
		);
	}
	return $msg;
}

sub rethrow ( $self ) {
	die( $self );
}

sub context_to_string ( $self, $ctx ) {
	return '' unless $ctx;
	return sprintf( '[%s:%d]', $ctx->{file}, $ctx->{line} );
}

1;
