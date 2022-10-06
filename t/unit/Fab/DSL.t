=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::DSL>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => 'Fab::DSL';
use Test2::Tools::Spec;

describe 'function `definition_context`' => sub {
	
	tests 'call function' => sub {
		
		my $ctx = Fab::DSL::definition_context( 0 );
		is(
			$ctx,
			hash {
				field package => string 'main';
				field file    => match qr/DSL\.t$/;
				field line    => D();
				end;
			},
			'expected context',
		);
	};
};

describe 'method `_exporter_validate_opts`' => sub {
	
	tests 'call method' => sub {
		
		my $called = 0;
		my $globals = {
			no_syntax_hack => 1,
			maker_class    => mock( {}, set => [ new => sub { ++$called; 'XYZ' } ] ),
		};
		$CLASS->_exporter_validate_opts( $globals );
		
		is( $called, 1, '$globals->{maker_class}->new was called' );
		is( $globals->{maker}, 'XYZ', '$globals->{maker} was set' );
		is( $Fab::MAKER, 'XYZ', '$Fab::MAKER was set' );
	};
};

sub generator_tests {
	my ( $keyword, $prototype, $call_with, $expected_args ) = @_;
	
	return sub {
		my $called = 0;
		my @called_args;
		my $globals = +{
			maker => mock( {}, set => [
				$keyword => sub {
					shift; ++$called; @called_args = @_;
					return mock( {}, set => [
						definition_context => sub {},
					] );
				},
			] ),
		};
		my $generator = '_generate_' . $keyword;
		my $got = $CLASS->$generator( $keyword, {}, $globals );
		
		is( ref($got), 'CODE', "$generator returned a coderef" );
		
		if ( defined $prototype ) {
			is( prototype($got), $prototype, "... with the correct prototype" );
		}
		
		if ( $call_with ) {
			
			$got->( $call_with->@* );
			
			is( $called, 1, 'Calling the coderef called the corresponding maker method' );
			is( \@called_args, $expected_args, '... and it was passed the expected arguments' )
				if $expected_args;
		}
	};
}

describe 'method `_generate_product`' => sub {
	
	my $CODE = sub {};
	
	tests 'call method' => generator_tests(
		product => undef,
		[ 'foo', as => $CODE, xyz => 123 ],
		bag {
			item 'foo';
			item 'as';                  item exact_ref( $CODE );
			item 'xyz';                 item 123;
			item 'definition_context';  item hash { etc; };
			end;
		},
	);
};

describe 'method `_generate_task`' => sub {
	
	my $CODE = sub {};
	
	tests 'call method' => generator_tests(
		task => undef,
		[ 'foo', as => $CODE, xyz => 123 ],
		bag {
			item 'foo';
			item 'as';                  item exact_ref( $CODE );
			item 'xyz';                 item 123;
			item 'definition_context';  item hash { etc; };
			end;
		},
	);
};

describe 'method `_generate_need`' => sub {
	tests 'call method' => generator_tests(
		need => undef,
		[ 'xyz' ],
		[ 'xyz' ],
	);
};

describe 'method `_generate_run`' => sub {
	tests 'call method' => generator_tests(
		run => undef,
		[ 'xyz' ],
		[ 'xyz' ],
	);
};

describe 'method `_generate_set`' => sub {
	tests 'call method' => generator_tests(
		set => undef,
		[ 'xyz', 123 ],
		[ 'xyz', 123 ],
	);
};

describe 'method `_generate_echo`' => sub {
	tests 'call method' => generator_tests(
		echo => undef,
		[ 'xyz' ],
		[ 'xyz' ],
	);
};

describe 'method `_generate_this`' => sub {
	tests 'call method' => generator_tests(
		this => '',
	);
};

describe 'method `_generate_stash`' => sub {
	tests 'call method' => generator_tests(
		stash => '',
	);
};

describe 'function `which`' => sub {
	
	tests 'it exists' => sub { ok exists &Fab::DSL::which; };
};

describe 'function `as`' => sub {
	
	tests 'it exists' => sub { ok exists &Fab::DSL::as; };
	tests 'it has the correct prototype' => sub { is prototype(\&Fab::DSL::as), '&'; };
};

describe 'package variable @EXPORT' => sub {
	
	tests 'lists correct functions' => sub {
		
		is(
			\@Fab::DSL::EXPORT,
			bag {
				item string 'product';
				item string 'task';
				item string 'as';
				item string 'need';
				item string 'run';
				item string 'set';
				item string 'this';
				item string 'stash';
				item string 'echo';
				item string 'which';
				end;
			},
		);
	};
};

describe 'package' => sub {
	
	tests 'it is an exporter' => sub {
		
		isa_ok $CLASS, 'Exporter::Tiny';
	};
};

done_testing;
