use Fab;

my $compiler = which $CONFIG{compiler};
my @clean;

product 'hello', as {
	need 'hello.o';
	run $compiler, '-g', '-o', this(), 'hello.o';
	push @clean, this;
};

product 'hello.o', as {
	run $compiler, '-c', '-Wall', '-g', 'hello.cpp';
	push @clean, this;
};

task ':compile', as {
	need 'hello';
};

task ':test', as {
	need 'hello';
	run './hello';
};

task ':clean', as {
	echo 'Running cleaning process';
	run sub { unlink($_) for @clean };
};

task ':TOP', as {
	need ':compile';
};
