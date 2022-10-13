=pod

=encoding utf-8

=head1 PURPOSE

Unit tests for L<Fab::BlueprintMaker::Stash>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test2::V0 -target => 'Fab::BlueprintMaker::Stash';
use Test2::Tools::Spec;

describe 'constructor `new`' => sub {
	
	tests 'it works' => sub {
		
		my $object = $CLASS->new( '$STASH' );
		
		is( ref($object), $CLASS, 'correct class' );
		is( $$object, '$STASH', 'correct object guts' );
	};
};

describe 'overload `@{}`' => sub {
	
	tests 'it works' => sub {
		
		my $object = $CLASS->new( '$STASH' );
		
		is(
			tied(@$object),
			object {
				prop isa => 'Fab::BlueprintMaker::Stash::ARRAY';
			},
			'returns tied array',
		);
	};
};

describe 'overload `%{}`' => sub {
	
	tests 'it works' => sub {
		
		my $object = $CLASS->new( '$STASH' );
		
		is(
			tied(%$object),
			object {
				prop isa => 'Fab::BlueprintMaker::Stash::HASH';
			},
			'returns tied hash',
		);
	};
};

describe 'method `resolve`' => sub {
	
	tests 'it works' => sub {
		
		my $code = '2 + $STASH';
		my $object = bless( \$code, $CLASS );
		
		is( $object->resolve( 40 ), 42, 'eval() returned correct result' );
	};
};

done_testing;
