use 5.020;
use strict;
use warnings;

package Fab::Features;

use experimental 'signatures';

sub _prelude ( $target ) {
	my ($package, $file, $line, $level)
		= ref $target         ? @{$target}{qw(package filename line level)}
		: $target =~ /[^0-9]/ ? ($target)
		: (undef, undef, undef, $target);
	if (defined $level) {
		my ($p, $fn, $ln) = caller($level + 2);
		$package ||= $p;
		$file    ||= $fn;
		$line    ||= $ln;
	}
	qq{package $package;\n}
		. ( $file ? "#line $line \"$file\"\n" : '' )
}

sub _make_action ( $action, $target ) {
	my $version = ref $target && $target->{version};
	eval _prelude($target)
		. q[sub {]
		. q[  my $module = shift;]
		. q[  eval "require $module";]
		. (ref $target && exists $target->{version} ? q[  $module->VERSION($version);] : q[])
		. q[  $module->].$action.q[(@_);]
		. q[}]
		or die "Failed to build action sub to ${action} for ${target}: $@";
}

sub import {
	require experimental;
	require feature;

	my $import   = _make_action( import   => 1 );
	my $unimport = _make_action( unimport => 1 );

	# use strict
	'strict'->$import();

	# use warnings
	'warnings'->$import();

	# use feature 'state';
	'feature'->$import( 'state' );

	# use feature 'try';
	if ( $] gt '5.034001' ) {
		'feature'->$import( 'try' );
		'warnings'->$unimport( 'experimental::try' );
	}
	else {
		require Syntax::Keyword::Try;
		'Syntax::Keyword::Try'->$import();
	}

	# use feature 'signatures';
	'feature'->$import( 'signatures' );
	'warnings'->$unimport( 'experimental::signatures' );

	# use Path::Tiny qw( path );
	require Path::Tiny;
	'Path::Tiny'->$import( 'path' );
}

1;
