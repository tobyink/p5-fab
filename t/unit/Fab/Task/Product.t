=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::Task::Product>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => 'Fab::Task::Product';
use Test2::Tools::Spec;
use Path::Tiny;

describe "class `$CLASS`" => sub {
	
	tests 'it has the expected attributes' => sub {
		
		can_ok $CLASS, $_ for
			qw( definition_context blueprint name id steps requirements );
	};
	
	tests 'it has the expected associated methods' => sub {
		
		can_ok $CLASS, $_ for
			qw( _push_step all_steps _push_requirement all_requirements );
	};
	
	tests 'it has an id' => sub {
		
		my $task = $CLASS->new(
			name      => 'TestForId',
			blueprint => mock( {}, set => [ isa => sub { 1 } ] ),
		);
		like( $task->id, qr/\A[1-9][0-9]*\z/, 'id field matches regexp for positive integers' );
	};

};

describe 'method `this`' => sub {
	
	my ( $tmp, $name, $expected );
	
	case 'with existing file' => sub {
		$tmp = Path::Tiny->tempfile;
		$tmp->spew('xyz');
		$name = "$tmp";
		$expected = object {
			prop isa       => 'Path::Tiny';
			call stringify => $name;
		};
	};
	
	case 'with non-existing file' => sub {
		$tmp = Path::Tiny->tempfile;
		$name = "$tmp";
		unlink( $tmp );
		$expected = object {
			prop isa       => 'Path::Tiny';
			call stringify => $name;
		};
	};
	
	tests 'it works' => sub {
		
		my $task = $CLASS->new(
			name      => $name,
			blueprint => mock( {}, set => [ isa => sub { 1 } ] ),
		);
		
		is( $task->this, $expected, 'this() returns expected value' );
	};
};

describe 'method `mtime`' => sub {
	
	my ( $tmp, $name, $expected );
	
	case 'with existing file' => sub {
		$tmp = Path::Tiny->tempfile;
		$tmp->spew('xyz');
		$name = "$tmp";
		$expected = number( $tmp->stat->mtime );
	};
	
	tests 'it works' => sub {
		
		my $task = $CLASS->new(
			name      => $name,
			blueprint => mock( {}, set => [ isa => sub { 1 } ] ),
		);
		
		is( $task->mtime, $expected, 'mtime() returns expected value' );
	};
};

describe 'method `file_exists`' => sub {
	
	my ( $tmp, $name, $expected );
	
	case 'with existing file' => sub {
		$tmp = Path::Tiny->tempfile;
		$tmp->spew('xyz');
		$name = "$tmp";
		$expected = T();
	};
	
	case 'with non-existing file' => sub {
		$tmp = Path::Tiny->tempfile;
		$name = "$tmp";
		unlink( $tmp );
		$expected = F();
	};
	
	tests 'it works' => sub {
		
		my $task = $CLASS->new(
			name      => $name,
			blueprint => mock( {}, set => [ isa => sub { 1 } ] ),
		);
		
		is( $task->file_exists, $expected, 'file_exists() returns expected value' );
	};
};

describe 'method `already_fabricated`' => sub {
	
	tests TODO => sub { pass; };
};

done_testing;
