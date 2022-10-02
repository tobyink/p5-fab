{
package Fab::Step;
use strict;
use warnings;
no warnings qw( once void );

our $USES_MITE = "Mite::Class";
our $MITE_SHIM = "Fab::Mite";
our $MITE_VERSION = "0.010008";
# Mite keywords
BEGIN {
    my ( $SHIM, $CALLER ) = ( "Fab::Mite", "Fab::Step" );
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

# Gather metadata for constructor and destructor
sub __META__ {
    no strict 'refs';
    my $class      = shift; $class = ref($class) || $class;
    my $linear_isa = mro::get_linear_isa( $class );
    return {
        BUILD => [
            map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
            map { "$_\::BUILD" } reverse @$linear_isa
        ],
        DEMOLISH => [
            map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
            map { "$_\::DEMOLISH" } @$linear_isa
        ],
        HAS_BUILDARGS => $class->can('BUILDARGS'),
        HAS_FOREIGNBUILDARGS => $class->can('FOREIGNBUILDARGS'),
    };
}


# Standard Moose/Moo-style constructor
sub new {
    my $class = ref($_[0]) ? ref(shift) : shift;
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    my $self  = bless {}, $class;
    my $args  = $meta->{HAS_BUILDARGS} ? $class->BUILDARGS( @_ ) : { ( @_ == 1 ) ? %{$_[0]} : @_ };
    my $no_build = delete $args->{__no_BUILD__};

    # Attribute definition_context (type: HashRef|Undef)
    # param declaration, file /home/tai/src/p5/p5-fab/lib/Fab/Step.pm, line 6
    if ( exists $args->{"definition_context"} ) { do { package Fab::Mite; (do { package Fab::Mite; ref($args->{"definition_context"}) eq 'HASH' } or do { package Fab::Mite; !defined($args->{"definition_context"}) }) } or croak "Type check failed in constructor: %s should be %s", "definition_context", "HashRef|Undef"; $self->{"definition_context"} = $args->{"definition_context"}; } ;

    # Attribute task (type: Undef|InstanceOf["Fab::Task"])
    # param declaration, file /home/tai/src/p5/p5-fab/lib/Fab/Step.pm, line 12
    croak "Missing key in constructor: task" unless exists $args->{"task"}; 
    do { package Fab::Mite; (do { package Fab::Mite; !defined($args->{"task"}) } or (do { use Scalar::Util (); Scalar::Util::blessed($args->{"task"}) and $args->{"task"}->isa(q[Fab::Task]) })) } or croak "Type check failed in constructor: %s should be %s", "task", "Undef|InstanceOf[\"Fab::Task\"]"; $self->{"task"} = $args->{"task"}; 
    require Scalar::Util && Scalar::Util::weaken($self->{"task"}) if ref $self->{"task"};


    # Call BUILD methods
    $self->BUILDALL( $args ) if ( ! $no_build and @{ $meta->{BUILD} || [] } );

    # Unrecognized parameters
    my @unknown = grep not( /\A(?:definition_context|task)\z/ ), keys %{$args}; @unknown and croak( "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

    return $self;
}

# Used by constructor to call BUILD methods
sub BUILDALL {
    my $class = ref( $_[0] );
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    $_->( @_ ) for @{ $meta->{BUILD} || [] };
}

# Destructor should call DEMOLISH methods
sub DESTROY {
    my $self  = shift;
    my $class = ref( $self ) || $self;
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    my $in_global_destruction = defined ${^GLOBAL_PHASE}
        ? ${^GLOBAL_PHASE} eq 'DESTRUCT'
        : Devel::GlobalDestruction::in_global_destruction();
    for my $demolisher ( @{ $meta->{DEMOLISH} || [] } ) {
        my $e = do {
            local ( $?, $@ );
            eval { $demolisher->( $self, $in_global_destruction ) };
            $@;
        };
        no warnings 'misc'; # avoid (in cleanup) warnings
        die $e if $e;       # rethrow
    }
    return;
}

my $__XS = !$ENV{PERL_ONLY} && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };

# Accessors for definition_context
# param declaration, file /home/tai/src/p5/p5-fab/lib/Fab/Step.pm, line 6
sub definition_context { @_ > 1 ? do { do { package Fab::Mite; ((ref($_[1]) eq 'HASH') or (!defined($_[1]))) } or croak( "Type check failed in %s: value should be %s", "accessor", "HashRef|Undef" ); $_[0]{"definition_context"} = $_[1]; $_[0]; } : ( $_[0]{"definition_context"} ) }

# Accessors for task
# param declaration, file /home/tai/src/p5/p5-fab/lib/Fab/Step.pm, line 12
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "task" => "task" },
    );
}
else {
    *task = sub { @_ == 1 or croak( 'Reader "task" usage: $self->task()' ); $_[0]{"task"} };
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