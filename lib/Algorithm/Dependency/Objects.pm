#!/usr/bin/perl

package Algorithm::Dependency::Objects;

use strict;
use warnings;

our $VERSION = '0.01';

use Scalar::Util qw/blessed/;
use Carp qw/croak/;

use Set::Object;

sub new {
	my ($pkg, %params) = @_;
	(exists $params{'objects'} && # objects is a require parameter
	    (blessed($params{'objects'}) && $params{'objects'}->isa('Set::Object')))
    	    || croak "You must provide an 'objects' parameter, and it must be a Set::Object";
    # all the contents of the Set::Object must have depends methods
    $_->can("depends") || croak "Objects must have a 'depends' method"
        foreach $params{'objects'}->members();  	    
	# selected is an optional parameter, and ...
    (blessed($params{'selected'}) && $params{'selected'}->isa('Set::Object') 
        && $params{'selected'}->subset($params{'objects'})) # must be a subset of objects
            || croak "'selected' parameter must be a Set::Object, and a subset of 'objects'"
                if exists $params{'selected'};	
	return bless {
	    objects  => $params{'objects'},
	    selected => $params{'selected'} || Set::Object->new
	}, $pkg;
}

sub objects  { (shift)->{objects}  }
sub selected { (shift)->{selected} }

sub depends {
	my $self = shift;
	my @queue = grep { $_->depends } @_;

	my $deps = Set::Object->new;
	my $sel = $self->selected;
	my $objs = $self->objects;

	while (@queue){
		my $obj = shift @queue;
		croak "$obj is not in objects!"
			unless $objs->contains($obj);
		next if $sel->contains($obj);
		next if $deps->contains($obj);

		my @new = Set::Object->new($obj->depends)->difference($sel)->members;
		push @queue, @new;
		$deps->insert(@new);
	}

	$deps->members;
}

sub schedule {
	my $self = shift;
	my $sel = $self->selected;

	return (
		$self->depends(@_),
		Set::Object->new(@_)->difference($self->selected)->members, # remove selected items
	);
}

sub schedule_all {
	my $self = shift;
	$self->objects->difference($self->selected)->members;
}

__PACKAGE__

__END__

=pod

=head1 NAME

Algorithm::Dependency::Objects - 

=head1 SYNOPSIS

	use Algorithm::Dependency::Objects;

=head1 DESCRIPTION

=cut
