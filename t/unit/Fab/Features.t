=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::Features>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => 'Fab::Features', -no_pragmas => 1;
use Test2::Tools::Spec;

describe 'use strict' => sub {
	tests 'it was set up' => sub {
		my $e = do {
			local $@;
			eval "package Local::ABC1; use $CLASS; \$xyz = 1;";
			$@;
		};
		
		like $e, qr/requires explicit package name/;
	};
};

describe 'use warnings' => sub {
	tests 'it was set up' => sub {
		my $e;
		my $w = warning {
			local $@;
			eval "package Local::ABC2; use $CLASS; my \$xyz; my \$xyz2 = 1 + \$xyz;";
			$e = $@;
		};
		
		is $e, F();
		like $w, qr/uninitialized value/;
	};
};

describe 'use feature qw(state)' => sub {
	tests 'it was set up' => sub {
		my $e = do {
			local $@;
			eval "package Local::ABC3; use $CLASS; state \$xyz = 1;";
			$@;
		};
		
		is $e, F();
	};
};

describe 'use feature qw(signatures)' => sub {
	tests 'it was set up' => sub {
		my $e = do {
			local $@;
			eval "package Local::ABC4; use $CLASS; sub xyz (\$x, \$y, \$z ) { \$x + \$z }; die unless xyz(1..3)==4;";
			$@;
		};
		
		is $e, F();
	};
};

describe 'use feature qw(try)' => sub {
	tests 'it was set up' => sub {
		my $e = do {
			local $@;
			eval "package Local::ABC5; use $CLASS; try { die; } catch ( \$e ) {};";
			$@;
		};
		
		is $e, F();
	};
};

describe 'use feature qw(try) with native implementation' => sub {
	tests 'it was set up' => sub {
		my $e = do {
			local $@;
			eval "package Local::ABC6; use $CLASS -try => 'native'; try { die; } catch ( \$e ) {};";
			$@;
		};
		
		is $e, F();
	};
} if $] ge '5.034001';

describe 'use feature qw(try) with module implementation' => sub {
	tests 'it was set up' => sub {
		my $e = do {
			local $@;
			eval "package Local::ABC7; use $CLASS -try => 'module'; try { die; } catch ( \$e ) {};";
			$@;
		};
		
		is $e, F();
	};
} if eval 'require Syntax::Keyword::Try; 1';

describe 'use Path::Tiny qw(path)' => sub {
	tests 'it was exported' => sub {
		my $e = do {
			local $@;
			eval "package Local::ABC8; use $CLASS;";
			$@;
		};
		
		is $e, F();
		isa_ok( Local::ABC8::path( 'foo' ), 'Path::Tiny' );
	};
};

done_testing;