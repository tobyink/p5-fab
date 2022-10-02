use Fab;

task '.TOP', as {
	need '.test';
};

task '.test', as {
	need '.compile-*';
	run 'prove -lr t';
};

task '.compile-mite', as {
	run 'mite -v';
};

go;
