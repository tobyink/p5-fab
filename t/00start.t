=pod

=encoding utf-8

=head1 PURPOSE

Print version numbers, etc.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use strict;
use warnings;
use Test2::V0;

my @modules = qw(
	Exporter::Tiny
	Hook::AfterRuntime
	Import::Into
	Path::Tiny
	Text::Glob
);

push @modules, 'Syntax::Keyword::Try'
	if $] lt '5.034001';

diag "\n####";
for my $mod ( @modules ) {
	eval "require $mod;";
	diag sprintf( '%s: %s', $mod, $mod->VERSION );
	ok $mod->VERSION, "found $mod version";
}
diag "####";

done_testing;