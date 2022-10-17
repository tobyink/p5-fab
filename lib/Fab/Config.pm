package Fab::Config;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

use Fab::Features;
use Fab::Mite ();
use YAML::PP qw( LoadFile );
use parent 'Exporter::Tiny';

our @EXPORT = qw( %CONFIG @CONFIG );

sub _path_to_config_file ( $class ) {
	return 'Fab.yml';
}

sub _exporter_validate_opts ( $class, $globals ) {
	
	$globals->{CONFIG} = [ {} ];
	
	$globals->{file} //= $class->_path_to_config_file;
	
	my $file = ( defined $globals->{dir} )
		? path( $globals->{dir}, $globals->{file} )
		: path(                  $globals->{file} );
	
	if ( $file->exists ) {
		$file->is_file or Fab::Mite::croak( "$file is not a file!" );
		
		my @docs = LoadFile( $file );
		$globals->{CONFIG} = \@docs;
	}
}

sub _generateHash_CONFIG ( $class, $name, $args, $globals ) {
	
	return $globals->{CONFIG}[0];
}

sub _generateArray_CONFIG ( $class, $name, $args, $globals ) {
	
	return $globals->{CONFIG};
}

1;
