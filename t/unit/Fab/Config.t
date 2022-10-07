=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::Config>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

BEGIN { $Fab::Config::_NO_AUTOLOAD_FILE = 1 };

use Test2::V0 -target => 'Fab::Config';
use Test2::Tools::Spec;

describe "package `$CLASS`" => sub {
	
	tests 'it is an exporter' => sub {
		
		isa_ok $CLASS, 'Exporter::Tiny';
	};
};

describe 'package variable `@EXPORT`' => sub {
	
	tests 'it lists correct exports' => sub {
		
		no warnings 'once';
		is(
			\@Fab::Config::EXPORT,
			bag {
				item string '%CONFIG';
				end;
			},
		);
	};
};

describe 'method `_docs_ref`' => sub {
	
	tests 'it works' => sub {
		
		no warnings 'once';
		is(
			$CLASS->_docs_ref,
			exact_ref( \@Fab::Config::DOCS ),
			'check the reference address returned',
		);
	};
};

describe 'method `_config_ref`' => sub {
	
	tests 'it works' => sub {
		
		no warnings 'once';
		is(
			$CLASS->_config_ref,
			exact_ref( \%Fab::Config::CONFIG ),
			'check the reference address returned',
		);
	};
};

describe 'method `_path_to_config_file`' => sub {
	
	tests 'it works' => sub {
		
		is(
			$CLASS->_path_to_config_file,
			string( 'Fab.yml' ),
			'correct filename',
		);
	};
};

sub TEST_DATA () { <<'YAML'; }
---
foo: 666
bar: 999

---
foo: 123
bar: 456
YAML

describe 'method `_load_file`' => sub {
	
	tests 'it works' => sub {
		
		my ( @docs, %config );
		my $guard = mock( $CLASS, set => [
			_docs_ref    => sub { \@docs },
			_config_ref  => sub { \%config },
		] );
		
		my $tempfile = 'Path::Tiny'->tempfile;
		$tempfile->spew( TEST_DATA );
		
		$CLASS->_load_file( $tempfile );
		
		is(
			\@docs,
			array {
				item hash {
					field foo => 666;
					field bar => 999;
					end;
				};
				item hash {
					field foo => 123;
					field bar => 456;
					end;
				};
				end;
			},
			'@DOCS',
		);
		
		is(
			\%config,
			hash {
				field foo => 666;
				field bar => 999;
				end;
			},
			'%CONFIG',
		);
	};
};

done_testing;
