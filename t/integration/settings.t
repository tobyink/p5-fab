=pod

=encoding utf-8

=head1 PURPOSE

Test Fab DSL set() keyword.

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

$Fab::NO_GO = 1;

my $blueprint = do {
	package Local::Test1;
	use Fab;
	
	task ':TOP', as {
		need ':simple', ':resetting';
	};
	
	task ':simple', as {
		set quux => 'xyzzy';
		run sub {
			::is( $Fab::CONTEXT->get_setting('quux'), 'xyzzy' );
		};
		set quux => 'quuux';
		run sub {
			::is( $Fab::CONTEXT->get_setting('quux'), 'quuux' );
		};
	};
	
	task ':resetting', as {
		need ':break-things';
		run sub {
			::is( $Fab::CONTEXT->get_setting('quux'), undef );
		};
	};
	
	task ':break-things', as {
		set quux => 'broken';
	};
	
	$Fab::MAKER->blueprint;
};

$blueprint->finalize;

use Fab::Context;

subtest "Run tests via Fab" => sub {
	plan 3;
	'Fab::Context'->new(
		blueprint => $blueprint,
		log_level => 5,
	)->fabricate( ':TOP' );
};

done_testing;

