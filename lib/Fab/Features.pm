use 5.028;
use strict;
use warnings;

package Fab::Features;

use Import::Into;
use experimental 'signatures';

sub import {
	require experimental;
	require feature;

	# use strict
	'strict'->import::into( 1 );

	# use warnings
	'warnings'->import::into( 1 );

	# use feature 'state';
	'feature'->import::into( 1, 'state' );

	# use feature 'try';
	if ( $] ge '5.034001' ) {
		'feature'->import::into( 1, 'try' );
		'warnings'->unimport::out_of( 1, 'experimental::try' );
	}
	else {
		require Syntax::Keyword::Try;
		'Syntax::Keyword::Try'->import::into( 1 );
	}

	# use feature 'signatures';
	'feature'->import::into( 1, 'signatures' );
	'warnings'->unimport::out_of( 1, 'experimental::signatures' );

	# use Path::Tiny qw( path );
	require Path::Tiny;
	'Path::Tiny'->import::into( 1, 'path' );
}

1;
