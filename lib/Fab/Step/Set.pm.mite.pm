{
package Fab::Step::Set;
use strict;
use warnings;
no warnings qw( once void );

our $USES_MITE = "Mite::Class";
our $MITE_SHIM = "Fab::Mite";
our $MITE_VERSION = "0.010008";
# Mite keywords
BEGIN {
    my ( $SHIM, $CALLER ) = ( "Fab::Mite", "Fab::Step::Set" );
    ( *after, *around, *before, *extends, *field, *has, *param, *signature_for, *with ) = do {
        package Fab::Mite;
        no warnings 'redefine';
        (
            sub { $SHIM->HANDLE_after( $CALLER, "class", @_ ) },
            sub { $SHIM->HANDLE_around( $CALLER, "class", @_ ) },
            sub { $SHIM->HANDLE_before( $CALLER, "class", @_ ) },
            sub {},
            sub { $SHIM->HANDLE_has( $CALLER, field => @_ ) },
            sub { $SHIM->HANDLE_has( $CALLER, has => @_ ) },
            sub { $SHIM->HANDLE_has( $CALLER, param => @_ ) },
            sub { $SHIM->HANDLE_signature_for( $CALLER, "class", @_ ) },
            sub { $SHIM->HANDLE_with( $CALLER, @_ ) },
        );
    };
};

# Mite imports
BEGIN {
    require Scalar::Util;
    *STRICT = \&Fab::Mite::STRICT;
    *bare = \&Fab::Mite::bare;
    *blessed = \&Scalar::Util::blessed;
    *carp = \&Fab::Mite::carp;
    *confess = \&Fab::Mite::confess;
    *croak = \&Fab::Mite::croak;
    *false = \&Fab::Mite::false;
    *guard = \&Fab::Mite::guard;
    *lazy = \&Fab::Mite::lazy;
    *ro = \&Fab::Mite::ro;
    *rw = \&Fab::Mite::rw;
    *rwp = \&Fab::Mite::rwp;
    *true = \&Fab::Mite::true;
};


BEGIN {
    require Fab::Step;
    
    use mro 'c3';
    our @ISA;
    push @ISA, "Fab::Step";
}

# Standard Moose/Moo-style constructor
sub new {
    my $class = ref($_[0]) ? ref(shift) : shift;
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    my $self  = bless {}, $class;
    my $args  = $meta->{HAS_BUILDARGS} ? $class->BUILDARGS( @_ ) : { ( @_ == 1 ) ? %{$_[0]} : @_ };
    my $no_build = delete $args->{__no_BUILD__};

    # Attribute definition_context (type: HashRef|Undef)
    # param declaration, file lib/Fab/Step.pm, line 9
    if ( exists $args->{"definition_context"} ) { do { package Fab::Mite; (do { package Fab::Mite; ref($args->{"definition_context"}) eq 'HASH' } or do { package Fab::Mite; !defined($args->{"definition_context"}) }) } or croak "Type check failed in constructor: %s should be %s", "definition_context", "HashRef|Undef"; $self->{"definition_context"} = $args->{"definition_context"}; } ;

    # Attribute task (type: Undef|InstanceOf["Fab::Task"])
    # param declaration, file lib/Fab/Step.pm, line 15
    croak "Missing key in constructor: task" unless exists $args->{"task"}; 
    do { package Fab::Mite; (do { package Fab::Mite; !defined($args->{"task"}) } or (do { use Scalar::Util (); Scalar::Util::blessed($args->{"task"}) and $args->{"task"}->isa(q[Fab::Task]) })) } or croak "Type check failed in constructor: %s should be %s", "task", "Undef|InstanceOf[\"Fab::Task\"]"; $self->{"task"} = $args->{"task"}; 
    require Scalar::Util && Scalar::Util::weaken($self->{"task"}) if ref $self->{"task"};

    # Attribute key (type: Str)
    # param declaration, file lib/Fab/Step/Set.pm, line 11
    croak "Missing key in constructor: key" unless exists $args->{"key"}; 
    do { package Fab::Mite; defined($args->{"key"}) and do { ref(\$args->{"key"}) eq 'SCALAR' or ref(\(my $val = $args->{"key"})) eq 'SCALAR' } } or croak "Type check failed in constructor: %s should be %s", "key", "Str"; $self->{"key"} = $args->{"key"}; 

    # Attribute value (type: Any)
    # param declaration, file lib/Fab/Step/Set.pm, line 16
    croak "Missing key in constructor: value" unless exists $args->{"value"}; 
    (!!1) or croak "Type check failed in constructor: %s should be %s", "value", "Any"; $self->{"value"} = $args->{"value"}; 


    # Call BUILD methods
    $self->BUILDALL( $args ) if ( ! $no_build and @{ $meta->{BUILD} || [] } );

    # Unrecognized parameters
    my @unknown = grep not( /\A(?:definition_context|key|task|value)\z/ ), keys %{$args}; @unknown and croak( "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

    return $self;
}

my $__XS = !$ENV{PERL_ONLY} && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };

# Accessors for key
# param declaration, file lib/Fab/Step/Set.pm, line 11
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "key" => "key" },
    );
}
else {
    *key = sub { @_ == 1 or croak( 'Reader "key" usage: $self->key()' ); $_[0]{"key"} };
}

# Accessors for value
# param declaration, file lib/Fab/Step/Set.pm, line 16
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "value" => "value" },
    );
}
else {
    *value = sub { @_ == 1 or croak( 'Reader "value" usage: $self->value()' ); $_[0]{"value"} };
}


# See UNIVERSAL
sub DOES {
    my ( $self, $role ) = @_;
    our %DOES;
    return $DOES{$role} if exists $DOES{$role};
    return 1 if $role eq __PACKAGE__;
    if ( $INC{'Moose/Util.pm'} and my $meta = Moose::Util::find_meta( ref $self or $self ) ) {
        $meta->can( 'does_role' ) and $meta->does_role( $role ) and return 1;
    }
    return $self->SUPER::DOES( $role );
}

# Alias for Moose/Moo-compatibility
sub does {
    shift->DOES( @_ );
}

1;
}