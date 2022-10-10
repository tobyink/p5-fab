package Fab::Utils::Internal;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

use Fab::Features;
use parent 'Exporter::Tiny';

our @EXPORT_OK = qw( rethrow );

sub rethrow {
	my ( $exception ) = @_;
	
	if ( Scalar::Util::blessed($exception) and $exception->isa( 'Fab::Exception' ) ) {
		my $next = $exception->can( 'rethrow' );
		@_ = $exception;
		goto $next;
	}
	
	die( $exception );
}

1;
