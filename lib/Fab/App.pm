package Fab::App;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

use Fab::Mite -all;
use Fab::Features;

sub _find_fab_pl ( $self ) {
	
	my $fab_pl;
	my $dir = path( '.' );
	while ( defined $dir and not defined $fab_pl ) {
		if ( $dir->child( 'Fab.pl' )->is_file ) {
			$fab_pl = path( $dir->child( 'Fab.pl' )->absolute );
			last;
		}
		$dir = $dir->parent;
	}
	
	$fab_pl or croak 'Could not find Fab.pl in any parent directory';
	
	return $fab_pl;
}

sub run ( $self ) {
	
	my $fab_pl = $self->_find_fab_pl;
	
	package main;
	$Fab::CHDIR_TARGET = $fab_pl->parent;
	do( $fab_pl );
	return 0;
}

1;
