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
	
	state $i = 0; ++$i;
	my $blueprint = do {
		local $@;
		local $Fab::MAKER;
		local $Fab::NO_GO = 1;
		my $text = $fab_pl->slurp;
		my $r = eval( "package Fab::Sandbox::Eval$i;\n#line 1 \"$fab_pl\"\n$text;\n1" );
		if ( not $r ) {
			warn "$@\n";
			return 2;
		}
		$Fab::MAKER->blueprint;
	};
	
	$blueprint->finalize;
	
	try {
		require Fab::Context;
		my $context = 'Fab::Context'->new( blueprint => $blueprint );
		$context->fabricate( '.TOP' );
		return 0;
	}
	catch ( $e ) {
		warn "$e";
		return 1;
	};
}

1;
