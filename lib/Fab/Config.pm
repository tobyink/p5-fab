package Fab::Config;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

use Fab::Features;
use Fab::Mite ();
use YAML::PP qw( LoadFile );
use parent 'Exporter::Tiny';

our ( %CONFIG, @DOCS );
our @EXPORT = qw( %CONFIG );

my $file = path( 'Fab.yml' );

if ( $file->exists ) {
	$file->is_file or Fab::Mite::croak( 'Fab.yml is not a file!' );
	@DOCS   = LoadFile( $file );
	%CONFIG = $DOCS[0]->%*;
}

1;
