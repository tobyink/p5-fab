use 5.028;
use strict;
use warnings;

package Fab;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001';

use Fab::Features;
use Fab::DSL ();

sub import ( $class ) {
	my $import = Fab::Features::_make_action( import => 1 );
	'Fab::Features'->$import();
	'Fab::DSL'->$import();
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Fab - fabrication

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Fab>.

=head1 SEE ALSO

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

