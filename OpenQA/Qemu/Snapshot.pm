# Copyright 2018 SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

=head2 OpenQA::Qemu::Snapshot

Represents the state of a virtual machine at a particular point in time. Not
much information about the snapshot is stored within this class itself, it is
used mainly as a reference to identify disperate objects as belonging to a
single snapshot.

We only consider snapshots which form a linear chain. Branching snapshots are
not supported.

=cut

package OpenQA::Qemu::Snapshot;
use Mojo::Base 'OpenQA::Qemu::MutParams';

has sequence => sub { return -1; };
has name     => sub { return 'none'; };
has 'previous';

sub equals {
    my ($self, $other) = @_;

    return $self->sequence == $other->sequence;
}

sub _to_map {
    my $self = shift;

    return {sequence => $self->sequence,
        name => $self->name};
}

sub CARP_TRACE {
    my $self = shift;

    return 'OpenQA::Qemu::Snapshot(' . $self->sequence . '|' . $self->name . ')';
}

1;
