=pod

=encoding utf-8

=head1 PURPOSE

Test that L<Fab::BlueprintMaker::Stash> works.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => 'Fab::BlueprintMaker::Stash';

my $stash1 = $CLASS->new( '$STASH' );

my $path1 = $stash1->[0]{foo}{bar}[1];
my $path2 = $stash1->[1][1];

my $STASH = [
	{ foo => { bar => [ 200 .. 209 ], baz => 300 } },
	[ 666, 999, 666 ],
];

is( $path1->resolve( $STASH ), 201 );
is( $path2->resolve( $STASH ), 999 );

done_testing;
