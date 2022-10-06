=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => 'Fab';
use Test2::Tools::Spec;

describe 'method `_make_inc_absolute`' => sub {
	
	tests 'call method' => sub {
		
		push @INC, 'this-directory-does-not-exist', \'some-reference';
		$CLASS->_make_inc_absolute;
		
		is( pop(@INC), \'some-reference', 'reference in @INC' );
		like( pop(@INC), qr{\Wthis-directory-does-not-exist.?$}i, 'relative path in @INC' );
	};
};

describe 'method `import`' => sub {
	
	tests 'call method' => sub {
		
		my $tmppkg = 'Local::ABC123';
		my $code = qq{
			package $tmppkg;
			use $CLASS dsl => [ -default, -no_syntax_hack ];
			1;
		};
		ok( eval($code), 'use Fab' );
		
		can_ok( $tmppkg, $_ ) for qw/
			product
			task
			as
			run
			set
			echo
			this
			path
			which
		/;
	};
};

done_testing;
