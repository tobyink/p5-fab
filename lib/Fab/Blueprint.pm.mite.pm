{
package Fab::Blueprint;
use strict;
use warnings;
no warnings qw( once void );

our $USES_MITE = "Mite::Class";
our $MITE_SHIM = "Fab::Mite";
our $MITE_VERSION = "0.010008";
# Mite keywords
BEGIN {
    my ( $SHIM, $CALLER ) = ( "Fab::Mite", "Fab::Blueprint" );
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
    # param declaration, file lib/Fab/Blueprint.pm, line 9
    if ( exists $args->{"definition_context"} ) { do { package Fab::Mite; (do { package Fab::Mite; ref($args->{"definition_context"}) eq 'HASH' } or do { package Fab::Mite; !defined($args->{"definition_context"}) }) } or croak "Type check failed in constructor: %s should be %s", "definition_context", "HashRef|Undef"; $self->{"definition_context"} = $args->{"definition_context"}; } ;

    # Attribute finalized (type: Bool)
    # field declaration, file lib/Fab/Blueprint.pm, line 15
    $self->{"finalized"} = do { my $default_value = false; (!ref $default_value and (!defined $default_value or $default_value eq q() or $default_value eq '0' or $default_value eq '1')) or croak( "Type check failed in default: %s should be %s", "finalized", "Bool" ); $default_value }; 


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

# Accessors for context
# field declaration, file lib/Fab/Blueprint.pm, line 41
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "context" => "context" },
    );
}
else {
    *context = sub { @_ == 1 or croak( 'Reader "context" usage: $self->context()' ); $_[0]{"context"} };
}
sub _assert_blessed_context { my $object = do { $_[0]{"context"} }; blessed($object) or croak( "context is not a blessed object" ); $object }
sub _set_context { 
    defined wantarray or croak( "This method cannot be called in void context" );
    my $get = "context";
    my $set = sub { blessed( $_[1] ) or croak( "Type check failed in %s: value should be %s", "local writer", "Object" ); $_[0]{"context"} = $_[1]; $_[0]; };
    my $has = sub { exists $_[0]{"context"} };
    my $clear = sub { delete $_[0]{"context"}; $_[0]; };
    my $old = undef;
    my ( $self, $new ) = @_;
    my $restorer = $self->$has
        ? do { $old = $self->$get; sub { $self->$set( $old ) } }
        : sub { $self->$clear };
    @_ == 2 ? $self->$set( $new ) : $self->$clear;
    &guard( $restorer, $old );
 }

# Delegated methods for context
# field declaration, file lib/Fab/Blueprint.pm, line 41
sub stash { shift->_assert_blessed_context->stash( @_ ) }

# Accessors for definition_context
# param declaration, file lib/Fab/Blueprint.pm, line 9
sub definition_context { @_ > 1 ? do { do { package Fab::Mite; ((ref($_[1]) eq 'HASH') or (!defined($_[1]))) } or croak( "Type check failed in %s: value should be %s", "accessor", "HashRef|Undef" ); $_[0]{"definition_context"} = $_[1]; $_[0]; } : ( $_[0]{"definition_context"} ) }

# Accessors for finalized
# field declaration, file lib/Fab/Blueprint.pm, line 15
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "finalized" => "finalized" },
    );
}
else {
    *finalized = sub { @_ == 1 or croak( 'Reader "finalized" usage: $self->finalized()' ); $_[0]{"finalized"} };
}

# Delegated methods for finalized
# field declaration, file lib/Fab/Blueprint.pm, line 15
*finalize = sub {
@_==1 or croak("Wrong number of parameters in signature for finalize; usage: "."\$instance->finalize()");
do { my $shv_real_invocant = $_[0]->finalized; ( $_[0]->{"finalized"} = do { my $shv_final_unchecked =  !!1 ; do { (!ref $shv_final_unchecked and (!defined $shv_final_unchecked or $shv_final_unchecked eq q() or $shv_final_unchecked eq '0' or $shv_final_unchecked eq '1')) or croak("Type check failed in delegated method: expected %s, got value %s", "Bool", $shv_final_unchecked); $shv_final_unchecked }; } ) }
};
# Accessors for task_lookup
# field declaration, file lib/Fab/Blueprint.pm, line 39
sub clear_task_lookup { @_ == 1 or croak( 'Clearer "clear_task_lookup" usage: $self->clear_task_lookup()' ); delete $_[0]{"task_lookup"}; $_[0]; }
sub task_lookup { @_ == 1 or croak( 'Reader "task_lookup" usage: $self->task_lookup()' ); ( exists($_[0]{"task_lookup"}) ? $_[0]{"task_lookup"} : ( $_[0]{"task_lookup"} = do { my $default_value = $_[0]->_build_task_lookup; (ref($default_value) eq 'HASH') or croak( "Type check failed in default: %s should be %s", "task_lookup", "HashRef" ); $default_value } ) ) }

# Accessors for tasks
# field declaration, file lib/Fab/Blueprint.pm, line 23
sub tasks { @_ == 1 or croak( 'Reader "tasks" usage: $self->tasks()' ); ( exists($_[0]{"tasks"}) ? $_[0]{"tasks"} : ( $_[0]{"tasks"} = do { my $default_value = []; do { package Fab::Mite; (ref($default_value) eq 'ARRAY') and do { my $ok = 1; for my $i (@{$default_value}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Fab::Task]) }) }; $ok } } or croak( "Type check failed in default: %s should be %s", "tasks", "ArrayRef[InstanceOf[\"Fab::Task\"]]" ); $default_value } ) ) }

# Delegated methods for tasks
# field declaration, file lib/Fab/Blueprint.pm, line 23
*_push_task = sub {
my $shv_self=shift;
for my $shv_value (@_) { do { (do { use Scalar::Util (); Scalar::Util::blessed($shv_value) and $shv_value->isa(q[Fab::Task]) }) or croak("Type check failed in delegated method: expected %s, got value %s", "InstanceOf[\"Fab::Task\"]", $shv_value); $shv_value }; }
my $shv_ref_invocant = do { $shv_self->tasks };
push(@{$shv_ref_invocant}, @_)
};
*all_tasks = sub {
@_==1 or croak("Wrong number of parameters in signature for all_tasks; usage: "."\$instance->all_tasks()");
my $shv_ref_invocant = do { $_[0]->tasks };
@{$shv_ref_invocant}
};

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