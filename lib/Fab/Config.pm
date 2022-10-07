package Fab::Config;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

use Fab::Features;
use Fab::Mite ();
use YAML::PP qw( LoadFile );
use parent 'Exporter::Tiny';

our @EXPORT = qw( %CONFIG );

sub _docs_ref ( $class ) {
	no strict 'refs';
	no warnings 'once';
	\@{"$class\::DOCS"};
}

sub _config_ref ( $class ) {
	no strict 'refs';
	no warnings 'once';
	\%{"$class\::CONFIG"};
}

sub _path_to_config_file ( $class ) {
	return 'Fab.yml';
}

sub _load_file ( $class, $path=undef ) {
	my $file = path( $path // $class->_path_to_config_file );
	
	if ( $file->exists ) {
		$file->is_file or Fab::Mite::croak( 'Fab.yml is not a file!' );
		
		my $docs = $class->_docs_ref;
		@$docs = LoadFile( $file );
		
		my $config = $class->_config_ref;
		%$config = $docs->[0]->%*;
	}
	
	return;
}

__PACKAGE__->_load_file unless $Fab::Config::_NO_AUTOLOAD_FILE;

1;
