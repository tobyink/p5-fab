{
package Fab::BlueprintMaker;
use strict;
use warnings;
no warnings qw( once void );

our $USES_MITE = "Mite::Class";
our $MITE_SHIM = "Fab::Mite";
our $MITE_VERSION = "0.010008";
# Mite keywords
BEGIN {
    my ( $SHIM, $CALLER ) = ( "Fab::Mite", "Fab::BlueprintMaker" );
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
    # param declaration, file /home/tai/src/p5/p5-fab/lib/Fab/BlueprintMaker.pm, line 6
    if ( exists $args->{"definition_context"} ) { do { package Fab::Mite; (do { package Fab::Mite; ref($args->{"definition_context"}) eq 'HASH' } or do { package Fab::Mite; !defined($args->{"definition_context"}) }) } or croak "Type check failed in constructor: %s should be %s", "definition_context", "HashRef|Undef"; $self->{"definition_context"} = $args->{"definition_context"}; } ;


    # Call BUILD methods
    $self->BUILDALL( $args ) if ( ! $no_build and @{ $meta->{BUILD} || [] } );

    # Unrecognized parameters
    my @unknown = grep not( /\Adefinition_context\z/ ), keys %{$args}; @unknown and croak( "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

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

# Accessors for _current_task
# field declaration, file /home/tai/src/p5/p5-fab/lib/Fab/BlueprintMaker.pm, line 20
sub _current_task { @_ > 1 ? do { blessed( $_[1] ) && $_[1]->isa( "Fab::Task" ) or croak( "Type check failed in %s: value should be %s", "accessor", "InstanceOf[\"Fab::Task\"]" ); $_[0]{"_current_task"} = $_[1]; $_[0]; } : ( $_[0]{"_current_task"} ) }
sub _clear__current_task { @_ == 1 or croak( 'Clearer "_clear__current_task" usage: $self->_clear__current_task()' ); delete $_[0]{"_current_task"}; $_[0]; }

# Accessors for blueprint
# field declaration, file /home/tai/src/p5/p5-fab/lib/Fab/BlueprintMaker.pm, line 18
sub blueprint { @_ == 1 or croak( 'Reader "blueprint" usage: $self->blueprint()' ); ( exists($_[0]{"blueprint"}) ? $_[0]{"blueprint"} : ( $_[0]{"blueprint"} = do { my $default_value = $_[0]->_build_blueprint; blessed( $default_value ) && $default_value->isa( "Fab::Blueprint" ) or croak( "Type check failed in default: %s should be %s", "blueprint", "InstanceOf[\"Fab::Blueprint\"]" ); $default_value } ) ) }

# Accessors for definition_context
# param declaration, file /home/tai/src/p5/p5-fab/lib/Fab/BlueprintMaker.pm, line 6
sub definition_context { @_ > 1 ? do { do { package Fab::Mite; ((ref($_[1]) eq 'HASH') or (!defined($_[1]))) } or croak( "Type check failed in %s: value should be %s", "accessor", "HashRef|Undef" ); $_[0]{"definition_context"} = $_[1]; $_[0]; } : ( $_[0]{"definition_context"} ) }


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