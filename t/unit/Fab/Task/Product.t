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
	
	my ( $task, $ctx, $expected, $expected_log, @guards, @log );
	
	before_case 'init case' => sub {
		$task = $ctx = $expected = $expected_log = undef;
		@guards = ();
		@log    = ();
	};
	
	case 'when context claims task was already fabricated, and file does not exist' => sub {
		$task = $CLASS->new(
			name      => 'file-does-not-exist.342342001',
			blueprint => mock( {}, set => [ isa => sub { 1 } ] ),
		);
		$ctx = mock( {}, set => [
			get_already_fabricated => sub {
				$_[1] == $task->id and return 1;
				fail 'Unexpected task id passed to get_already_fabricated';
			},
		] );
		$expected = T();
	};
	
	case 'when context claims task was not already fabricated, and file does not exist' => sub {
		$task = $CLASS->new(
			name      => 'file-does-not-exist.342342002',
			blueprint => mock( {}, set => [ isa => sub { 1 } ] ),
		);
		$ctx = mock( {}, set => [
			get_already_fabricated => sub {
				$_[1] == $task->id and return 0;
				fail 'Unexpected task id passed to get_already_fabricated';
			},
		] );
		$expected = F();
	};
	
	case 'when context claims task was not already fabricated, but file does exist and has no prereqs' => sub {
		my $tmp = Path::Tiny->tempfile;
		$tmp->spew( 'xyz' );
		push @guards, $tmp;
		
		$task = $CLASS->new(
			name      => "$tmp",
			blueprint => mock( {}, set => [ isa => sub { 1 } ] ),
		);
		$ctx = mock( {}, set => [
			get_already_fabricated => sub {
				$_[1] == $task->id and return 0;
				fail 'Unexpected task id passed to get_already_fabricated';
			},
		] );
		$expected = T();
	};
	
	# case 'when context claims task was not already fabricated, but file does exist, yet has non-product prereqs which have run'
	
	# case 'when context claims task was not already fabricated, but file does exist, yet has non-product prereqs which have not run'
	
	# case 'when context claims task was not already fabricated, but file does exist, yet has product prereqs which do not exist'
	
	# case 'when context claims task was not already fabricated, but file does exist, yet has product prereqs which do exist and are newer than me'
	
	# case 'when context claims task was not already fabricated, but file does exist, yet has product prereqs which do exist and are older than me'
	
	tests 'it works' => sub {
		
		my $got = $task->already_fabricated( $ctx );
		is( $got, $expected, 'got expected response' );
		is( \@log, $expected_log, 'got expected log' ) if defined $expected_log;
	};
};

done_testing;
