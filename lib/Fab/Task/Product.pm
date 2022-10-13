package Fab::Task::Product;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

use Fab::Mite -all;
use Fab::Features;

extends 'Fab::Task';

sub this ( $self ) {
	return path( $self->name );
}

sub mtime ( $self ) {
	return $self->this->stat->mtime;
}

sub file_exists ( $self ) {
	return $self->this->exists;
}

around already_fabricated => sub ( $next, $self, $context ) {
	
	my $this = $self->this;
	
	return true if $self->$next( $context );
	return false unless $self->file_exists;
	
	# Our file exists, so we MIGHT be able to return true!
	
	# But first check all of the tasks we require...
	for my $req ( $self->expand_requirements( $context ) ) {
		# If they are a product, then...
		if ( $req->isa( __PACKAGE__ ) ) {
			# We can't return true if they don't exist.
			return false unless $req->file_exists;
			# We can't return true if they are newer than us.
			return false if $req->mtime > $self->mtime;
		}
		# Otherwise it's just a plain task, so...
		else {
			# We can't return true unless they were already run.
			return false unless $req->already_fabricated( $context );
		}
	}
	
	# XXX: also check Fab.pl and Fab.yml's mtimes
	
	# Yay!
	$context->log( debug => 'Product "%s" already exists!', $self->name );
	return true;
};

# XXX: postrequisites

1;
