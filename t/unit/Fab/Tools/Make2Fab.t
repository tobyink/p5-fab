=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::Tools::Make2Fab>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => 'Fab::Tools::Make2Fab';
use Test2::Tools::Spec;
use Test2::Require::Module 'Makefile::Parser';
use Path::Tiny;
use Data::Dumper;

describe 'method `_build_parsed`' => sub {
	
	my @tempfiles;
	my $input;
	my $makefile = <<'MAKEFILE';
CC=mycc

foo.o:
	$(CC) -c -Wall -g foo.c

foo: foo.o
	$(CC) -g -o foo foo.o
MAKEFILE
	
	case 'ScalarRef input' => sub {
		my $str = $makefile;
		$input = \$str;
	};
	
	case 'Path::Tiny input' => sub {
		my $tmp = 'Path::Tiny'->tempfile;
		$tmp->spew( $makefile );
		push @tempfiles, $tmp;
		$input = $tmp;
	};
	
	case 'Filename input' => sub {
		my $tmp = 'Path::Tiny'->tempfile;
		$tmp->spew( $makefile );
		push @tempfiles, $tmp;
		$input = $tmp->stringify;
	};
	
	case 'FileHandle input' => sub {
		my $tmp = 'Path::Tiny'->tempfile;
		$tmp->spew( $makefile );
		push @tempfiles, $tmp;
		$input = $tmp->openr;
	};
	
	case 'IO::Handle input' => sub {
		my $tmp = 'Path::Tiny'->tempfile;
		$tmp->spew( $makefile );
		push @tempfiles, $tmp;
		
		require IO::File;
		$input = 'IO::File'->new;
		$input->open( "< $tmp" );
	};
	
	tests "gives expected parsed result" => sub {
		my $object = $CLASS->new( input => $input );
		my $parsed = $object->_build_parsed;
		
		is( $parsed->var('CC'), 'mycc', 'var' );
		is( [ $parsed->target('foo')->depends ], [ 'foo.o' ], 'target depends' );
		is( [ $parsed->target('foo')->commands ], [ 'mycc -g -o foo foo.o' ], 'target commands' );
	};
};

describe 'method `_build_output_header`' => sub {
	
	tests "gives expected string" => sub {
		
		my $object = $CLASS->new( input => \'' );
		
		like( $object->_build_output_header, qr/use Fab/ );
	};
};

describe 'method `_build_output_vars`' => sub {
	
	tests "gives expected string" => sub {
		
		my $object = $CLASS->new( input => \'' );
		$object->{parsed} = mock( {}, set => [
			vars => sub { qw/ XXX YYY ZZZ / },
			var  => sub { +{qw/ XXX 111 YYY 222 ZZZ 333 /}->{pop()} },
		] );
		
		is( $object->_build_output_vars, <<'VARS' );
my $XXX                = "111";
my $YYY                = "222";
my $ZZZ                = "333";

VARS
	};
};

describe 'method `_build_output_targets`' => sub {
	
	tests "gives expected string" => sub {
		
		my $object = $CLASS->new( input => \'' );
		$object->{parsed} = mock( {}, set => [
			targets => sub {
				return (
					mock( {}, set => [
						name     => sub { 'quux' },
						depends  => sub { return; },
						commands => sub { return; },
					] ),
					mock( {}, set => [
						name     => sub { 'foo' },
						depends  => sub { 'bar' },
						commands => sub { 'baz' },
					] ),
				);
			},
		] );
		
		is( $object->_build_output_targets, <<'TARGETS' );
product "quux", as {};

product "foo", as {
	need "bar";
	run "baz";
};
TARGETS
	};
};

describe 'method `_build_output`' => sub {
	
	tests "gives expected string" => sub {
		
		my $object = $CLASS->new( input => \'' );
		my $guard  = mock( $object, set => [
			_build_output_header  => sub { 'x' },
			_build_output_vars    => sub { 'y' },
			_build_output_targets => sub { 'z' },
		] );
		
		is( $object->_build_output, 'xyz' );
	};
};

describe 'method `clean_command`' => sub {
	
	my ( $command, $expected );
	
	case "just needs quoting" => sub {
		$command  = 'foo bar';
		$expected = q{"foo bar"};
	};
	
	case "too much whitespace" => sub {
		$command  = '   foo  bar     ';
		$expected = q{"foo  bar"};
	};
	
	case "contains comment" => sub {
		$command  = 'foo # hello';
		$expected = q{"foo"};
	};
	
	case "contains variable" => sub {
		$command  = 'foo $(MYVAR)';
		$expected = q{"foo $MYVAR"};
	};
	
	tests "gives expected string" => sub {
		
		my $object = $CLASS->new( input => \'' );
		
		is( $object->clean_command( $command ), $expected );
	};
};

done_testing;

