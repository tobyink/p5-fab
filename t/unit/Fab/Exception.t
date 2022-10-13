=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::Exception>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => { ROLE => 'Fab::Exception' };
use Test2::Tools::Spec;

describe "role `$ROLE`" => sub {
	
	tests 'it is a Mite role' => sub {
		
		is( $Fab::Exception::USES_MITE, 'Mite::Role', 'check $USES_MITE' );
	};
};

describe "method `throw`" => sub {
	
	tests 'it works' => sub {
		
		my @got;
		my $class = mock( {}, set => [
			new    => sub { shift; @got = @_; bless {}, 'Local::Test' },
			throw  => $ROLE->can( 'throw' ),
		] );
		
		my $e = dies {
			$class->throw( abc => 123 );
		};
		
		is(
			\@got,
			[ abc => 123 ],
			'new() was passed correct arguments',
		);
		
		is(
			$e,
			object { prop isa => 'Local::Test' },
			'exception was thrown',
		);
	};
};

describe "method `to_string`" => sub {
	
	my ( $exception, $expected );
	
	case 'with exception and no original_exception' => sub {
		
		$exception = mock( {}, set => [
			has_original_exception => sub { !!0 },
			message                => "Foo",
		] );
		$expected = string "Foo\n";
	};
	
	case 'with exception and string original_exception' => sub {
		
		$exception = mock( {}, set => [
			has_original_exception => sub { !!1 },
			original_exception     => sub { "Bar" },
			message                => sub { "Foo" },
		] );
		$expected = string "Foo\n\tbecause: Bar\n";
	};
	
	case 'with exception and Fab original_exception' => sub {
		
		my $orig_exception = mock( {}, set => [
			DOES                   => sub { $_[1] eq $ROLE },
			to_string              => sub { "Baz\n" },
		] );
		
		$exception = mock( {}, set => [
			has_original_exception => sub { !!1 },
			original_exception     => sub { $orig_exception },
			message                => sub { "Foo" },
		] );
		$expected = string "Foo\n\tbecause: Baz\n";
	};
	
	tests 'it works' => sub {
		
		my $method = $ROLE->can( 'to_string' );
		my $got    = $exception->$method;
		
		is( $got, $expected, 'expected result' );
	};
};

describe "method `rethrow`" => sub {
	
	tests 'it works' => sub {
		
		my $exception = mock( {}, set => [
			flag     => sub { 42 },
			rethrow  => $ROLE->can( 'rethrow' ),
		] );
		
		my $got = dies { $exception->rethrow; undef };
		
		is( $got->flag, 42, 'invocant was thrown' );
	};
};

describe "method `context_to_string`" => sub {
	
	my ( $context, $expected );
	
	case 'with no context' => sub {
		$context  = undef;
		$expected = string '';
	};
	
	case 'with sensible context' => sub {
		$context  = { file => 'Foo.pl', line => 42 };
		$expected = string '[Foo.pl:42]';
	};
	
	tests 'it works' => sub {
		
		is( $ROLE->context_to_string($context), $expected, 'expected output' );
	};
};

done_testing;
