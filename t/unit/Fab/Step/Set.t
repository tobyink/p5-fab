=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::Step::Set>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => 'Fab::Step::Set';
use Test2::Tools::Spec;

describe "method `execute`" => sub {
	
	my ( $testing_key, $testing_value );
	my ( $expected_key, $expected_value );
	
	case 'simple string value' => sub {
		( $testing_key,  $testing_value  ) = ( 'foo', 'bar' );
		( $expected_key, $expected_value ) = ( 'foo', 'bar' );
	};
	
	case 'reference value' => sub {
		( $testing_key,  $testing_value  ) = ( 'foo', [ 'bar' ] );
		( $expected_key, $expected_value ) = ( 'foo', array { item string 'bar' } );
	};
	
	tests 'call method' => sub {
		
		my @got;
		my $mock_context = mock( {}, set => [
			set_setting => sub { shift; @got = @_ },
		] );
		my $mock_task = mock( {}, set => [
			isa => sub { 1 },
		] );
		
		my $object = $CLASS->new(
			key   => $testing_key,
			value => $testing_value,
			task  => $mock_task,
		);
		$object->execute( $mock_context );
		
		is(
			\@got,
			[ $expected_key, $expected_value ],
			'set_setting was passed the correct arguments',
		);
	};
};

done_testing;
