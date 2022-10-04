=pod

=encoding utf-8

=head1 PURPOSE

Test that Fab DSL works.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0;
use Test2::Require::AuthorTesting;
use Test2::Require::Module qw( Capture::Tiny );
use Capture::Tiny qw( capture_stderr );
use FindBin qw( $Bin );
no warnings 'once';

my $dir = "$Bin/hello-world";
chdir( $Fab::CHDIR_TARGET = $dir );
my $stderr = capture_stderr {
	do( './Fab.pl' );
};

like( $stderr, qr/Task: ":compile"/, ':compile task was run' );
like( $stderr, qr/Task: "hello"/, 'hello task was run' );
like( $stderr, qr/Task: "hello.o"/, 'hello.o task was run' );

my $output = `./hello`;
like( $output, qr/Hello, world/, 'correct executable built' );

'Fab::Context'->new(
	blueprint => $Fab::MAKER->blueprint,
	log_level => 5,
)->fabricate( ':clean' );

done_testing;
