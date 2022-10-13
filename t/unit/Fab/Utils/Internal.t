=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::Utils::Internal>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => 'Fab::Utils::Internal';
use Test2::Tools::Spec;

describe "package `$CLASS`" => sub {
	
	tests 'it is an exporter' => sub {
		
		isa_ok $CLASS, 'Exporter::Tiny';
	};
};

describe 'package variable `@EXPORT_OK`' => sub {
	
	tests 'it lists correct functions' => sub {
		
		is(
			\@Fab::Utils::Internal::EXPORT_OK,
			bag {
				item string 'rethrow';
				end;
			},
		);
	};
};

describe 'function `rethrow`' => sub {
	
	tests 'it can rethrow strings' => sub {
		
		my $e = dies {
			Fab::Utils::Internal::rethrow( 'Foo' );
		};
		
		is( ref($e), F(), '$e is non-reference' );
		like( $e, qr/^Foo/, '$e matches /^Foo/' );
	};
	
	tests 'it can rethrow objects' => sub {
		
		my $e = dies {
			Fab::Utils::Internal::rethrow( bless( {}, 'Local::Class' ) );
		};
		
		is( $e, object { prop isa => 'Local::Class' }, '$e is expected object' );
	};
	
	tests 'it can rethrow Fab::Exception objects' => sub {
		
		my $rethrown;
		my $FE = mock( {}, set => [
			DOES    => sub { $_[1] eq 'Fab::Exception' },
			rethrow => sub { ++$rethrown; die( $_[0] ) },
		] );
		
		my $e = dies {
			Fab::Utils::Internal::rethrow( $FE );
		};
		
		is( ref($e), T(), '$e is a ref' );
		is( $rethrown, 1, 'rethrown() method was called once' );
	};
};

done_testing;
