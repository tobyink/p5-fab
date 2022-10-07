=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::Step::Echo>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => 'Fab::Step::Echo';
use Test2::Tools::Spec;
use Path::Tiny qw( path );

describe "class `$CLASS`" => sub {
	
	tests 'it is a Fab::Step' => sub {
		
		isa_ok $CLASS, 'Fab::Step';
	};
	
	tests 'it has the expected attributes' => sub {
		
		can_ok $CLASS, $_ for
			qw( args definition_context task );
	};
};

describe "method `execute`" => sub {
	
	my ( $test_args, $expected );
	
	case 'with simple string values' => sub {
		$test_args = [         qw/ foo bar baz / ];
		$expected  = [ info => qw/ foo bar baz / ];
	};
	
	case 'with values including paths' => sub {
		$test_args = [         qw/ foo bar /, path( 'baz' ) ];
		$expected  = [ info => qw/ foo bar /,       'baz'   ];
	};
	
	tests 'it works' => sub {
		
		my @got;
		my $mock_context = mock( {}, set => [
			log => sub { shift; @got = @_ },
		] );
		my $mock_task = mock( {}, set => [
			isa => sub { 1 },
		] );
		
		my $object = $CLASS->new(
			args  => $test_args,
			task  => $mock_task,
		);
		$object->execute( $mock_context );
		
		is(
			\@got,
			$expected,
			'log was passed the correct arguments',
		);
	};
};

describe "method `_process_args`" => sub {

	tests 'it works' => sub {
		
		my @got;
		my $object = $CLASS->new(
			args  => [ qw/ a b c / ],
			task  => mock( {}, set => [ isa => sub { 1 } ] ),
		);
		my $guard = mock( $object, set => [
			_process_arg => sub { shift; push @got, [ @_ ]; uc( $_[0] ) }
		] );
		my @return = $object->_process_args( mock( {} ) );
		
		is(
			\@got,
			bag {
				item array {
					item string 'a';
					item object {};
					end;
				};
				item array {
					item string 'b';
					item object {};
					end;
				};
				item array {
					item string 'c';
					item object {};
					end;
				};
				end;
			},
			'_process_arg passed correct values',
		);
		
		is(
			\@return,
			[ qw/ A B C / ],
			'returned correct values'
		);
	};
};

describe "method `_process_arg`" => sub {
	
	my ( $test_arg, $expected, $stash_call_expected );
	
	case 'with simple string value' => sub {
		$test_arg = 'foo';
		$expected = 'foo';
		$stash_call_expected = 0;
	};
	
	case 'with path' => sub {
		$test_arg = path( 'bar' );
		$expected =       'bar';
		$stash_call_expected = 0;
	};
	
	case 'with stash reference' => sub {
		$test_arg = mock( {}, set => [
			isa     => sub { pop eq 'Fab::BlueprintMaker::Stash' },
			resolve => sub { pop->{is_ok} or die; 'baz' },
		] );
		$expected = 'baz';
		$stash_call_expected = 1;
	};
	
	tests 'it works' => sub {
		
		my $stash_called = 0;
		my $mock_context = mock( {}, set => [
			stash => sub {
				++$stash_called;
				return { is_ok => 1 };
			},
		] );
		
		my $object = $CLASS->new(
			task  => mock( {}, set => [ isa => sub { 1 } ] ),
		);
		my $got = $object->_process_arg( $test_arg, $mock_context );
		
		is(
			$stash_called,
			$stash_call_expected,
			'Stash consulted the correct number of times',
		);
		
		is(
			$got,
			$expected,
			'_process_arg returned the correct value',
		);
	};
};

done_testing;
