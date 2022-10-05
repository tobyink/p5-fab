package Fab::Tools::Make2Fab;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.000_001';

use Fab::Mite -all;
use Fab::Features;

use B ();

param input => (
	is          => ro,
	isa         => 'ScalarRef|Path::Tiny|FileHandle|Str',
	required    => true,
);

field parsed => (
	isa         => 'Object',
	builder     => true,
);

field output => (
	isa         => 'Str',
	builder     => true,
);

sub _build_parsed ( $self ) {
	
	my $input  = $self->input;
	
	if (
		( ref $input and Scalar::Util::openhandle($input) ) or
		( blessed $input and $input->isa( 'IO::Handle' ) )
	) {
		
		my $slurp = do { local $/; <$input> };
		$input = \$slurp;
	}
	
	if ( ref $input eq 'SCALAR' ) {
		
		my $tmp = 'Path::Tiny'->tempfile;
		$tmp->spew( $$input );
		$input = $tmp;
	}
	
	require Makefile::Parser;
	my $parser = 'Makefile::Parser'->new;
	$parser->parse( $input );
	
	return $parser;
}

sub _build_output ( $self ) {
	
	my $output = '';
	$output .= $self->_build_output_header;
	$output .= $self->_build_output_vars;
	$output .= $self->_build_output_targets;
	
	return $output;
}

sub _build_output_header ( $self ) {
	
	return "use Fab;\n\n";
}

sub _build_output_vars ( $self ) {
	
	my $parsed = $self->parsed;
	my $output = '';
	
	for my $var ( $parsed->vars ) {
		
		$output .= sprintf(
			'my $%-18s = %s;',
			$var,
			B::perlstring( $parsed->var( $var ) ),
		) . "\n";
	}
	
	$output .= "\n";
	
	return $output;
}

sub _build_output_targets ( $self ) {
	
	my $parsed = $self->parsed;
	my $output = '';
	
	for my $target ( $parsed->targets ) {
		
		use Data::Dumper;
		$output .= sprintf(
			"product %s, as {%s" .
			"%s" .
			"%s" .
			"};\n\n",
			B::perlstring( $target->name ),
			( $target->depends || $target->commands ? "\n" : '' ),
			join( q{}, map sprintf( qq{\tneed %s;\n}, B::perlstring($_) ), $target->depends ),
			join( q{}, map sprintf( qq{\trun %s;\n}, $_ ), map $self->clean_command($_), $target->commands ),
		);
	}
	
	chomp $output;
	
	return $output;
}

sub clean_command ( $self, $command ) {
	$command =~ s/^\s*\@//;
	$command =~ s/^\s*\-//;
	$command =~ s/\s*#.+$//s;
	$command =~ s/^\s+|\s+$//gs;
	
	$command = B::perlstring( $command );
	
	$command =~ s/\\\$\((\w+)\)/\$$1/g;
	
	return $command;
}

1;
