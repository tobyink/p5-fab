=pod

=encoding utf-8

=head1 PURPOSE

Test that Fab DSL can be used to create a simple Fab file.

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
use Data::Dumper;

my ( $abc, $def, $xyz, @xyz );
$xyz = 0;

$Fab::NO_GO = 1;

my $blueprint = do {
	package Local::Test1;
	use Fab;
	
	task 'abc', as {
		need 'def', qr/xyz/;
		run sub { $abc = $_[0] }, 123;
	};
	
	task 'def', as {
		need 'xy*';
		run sub { $def = $_[0] }, 456;
	};
	
	task 'xyz', as {
		run sub { push @xyz, @_ }, 789, 0;
		run sub {
			run sub { ++$xyz };
		};
	};
	
	$Fab::MAKER->blueprint;
};

$blueprint->finalize;

use Fab::Context;

subtest "Run Fab and ask for a leaf" => sub {
	( $abc, $def, $xyz, @xyz ) = ( undef ) x 3;
	
	my $ctx = 'Fab::Context'->new( blueprint => $blueprint, log_level => 5 );
	$ctx->fabricate( 'xyz' );
	
	is( $xyz, 1, 'Task "xyz" was run once' );
	is( \@xyz, [ 789, 0 ], '... and correctly' );
	is( $abc, undef, 'Task "abc" was not run' );
	is( $def, undef, 'Task "def" was not run' );
};

subtest "Run Fab and ask for a node with dependencies" => sub {
	( $abc, $def, $xyz, @xyz ) = ( undef ) x 3;
	
	my $ctx = 'Fab::Context'->new( blueprint => $blueprint, log_level => 5 );
	$ctx->fabricate( 'abc' );
	
	is( $xyz, 1, 'Task "xyz" was run once' );
	is( \@xyz, [ 789, 0 ], '... and correctly' );
	is( $abc, 123, 'Task "abc" was run' );
	is( $def, 456, 'Task "def" was run' );
};

done_testing;

