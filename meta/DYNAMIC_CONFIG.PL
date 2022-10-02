	use strict;
	use warnings;
	no warnings 'uninitialized';
	
	if ( $] lt 5.034001 ) {
		$meta->{prereqs}{runtime}{requires}{'Syntax::Keyword::Try'} = 0;
	}
