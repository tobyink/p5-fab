package Fab::App;

use Fab::Mite -all;
use Fab::Features;

sub run ( $self ) {
	
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
	
	package main;
	$Fab::CHDIR_TARGET = $dir;
	do( $fab_pl );
	return 0;
}

1;
