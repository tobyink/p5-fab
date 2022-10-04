use 5.028;
use strict;
use warnings;

package Fab::Features;

use Import::Into;
use experimental 'signatures';

sub import ( $class, %opts ) {
	require experimental;
	require feature;

	$opts{'-try'} //= ( $] ge '5.034001' ) ? 'native' : 'module';

	# use strict
	'strict'->import::into( 1 );

	# use warnings
	'warnings'->import::into( 1 );

	# use feature 'state';
	'feature'->import::into( 1, 'state' );

	# use feature 'try';
	if ( $opts{'-try'} eq 'native' ) {
		'feature'->import::into( 1, 'try' );
		'warnings'->unimport::out_of( 1, 'experimental::try' );
	}
	elsif ( $opts{'-try'} eq 'module' ) {
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

__END__

=pod

=encoding utf-8

=head1 NAME

Fab::Features - exports 'strict', 'warnings', etc.

=head1 SYNOPSIS

  use Fab::Features;
  
  # equivalent to:
  #
  # use strict;
  # use warnings;
  # use feature qw( state signatures try );
  # no warnings qw( experimental::signatures experimental::try );
  # use Path::Tiny qw( path );

=head1 DESCRIPTION

This module requires Perl 5.28+.

The C<try> feature was only added in Perl 5.34 and a major bug was fixed
in Perl 5.34.1, so on Perl older than 5.34.1, Fab::Features will load
L<Syntax::Keyword::Try> instead of using the experimental builtin C<try>
keyword.

=head1 BUGS

Please report any bugs to
L<https://github.com/tobyink/p5-fab/issues>.

=head1 SEE ALSO

L<strictures>, L<Modern::Perl>, L<common::sense>, etc.

L<Fab>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

