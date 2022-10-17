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

use Test2::V0 -target => 'Fab::Config';
use Test2::Tools::Spec;
use Path::Tiny;

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
				item string '@CONFIG';
				end;
			},
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

describe 'method `_exporter_validate_opts`' => sub {
	
	tests 'it works' => sub {
		
		my $tmp = 'Path::Tiny'->tempfile();
		$tmp->spew( TEST_DATA );
		
		my $globals = {
			file => $tmp->basename,
			dir  => $tmp->parent->stringify,
		};
		
		$CLASS->_exporter_validate_opts( $globals );
		
		is(
			$globals,
			hash {
				field file   => D();
				field dir    => D();
				field CONFIG => array {
					item hash {
						field foo => number 666;
						field bar => number 999;
						end;
					};
					item hash {
						field foo => number 123;
						field bar => number 456;
						end;
					};
					end;
				};
				end;
			},
			'modified $globals hash as expected',
		);
	};
};

describe 'method `_generateArray_CONFIG`' => sub {
	
	tests 'it works' => sub {
		
		my $globals = { CONFIG => [ {}, {} ] };
		
		is(
			$CLASS->_generateArray_CONFIG( '@CONFIG', {}, $globals ),
			exact_ref( $globals->{CONFIG} ),
		);
	};
};

describe 'method `_generateHash_CONFIG`' => sub {
	
	tests 'it works' => sub {
		
		my $globals = { CONFIG => [ {}, {} ] };
		
		is(
			$CLASS->_generateHash_CONFIG( '%CONFIG', {}, $globals ),
			exact_ref( $globals->{CONFIG}[0] ),
		);
	};
};

done_testing;
