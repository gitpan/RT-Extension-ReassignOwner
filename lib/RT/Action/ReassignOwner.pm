# BEGIN BPS TAGGED BLOCK {{{
# 
# COPYRIGHT:
#  
# This software is Copyright (c) 1996-2007 Best Practical Solutions, LLC 
#                                          <jesse@bestpractical.com>
# 
# (Except where explicitly superseded by other copyright notices)
# 
# 
# LICENSE:
# 
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from www.gnu.org.
# 
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 or visit their web page on the internet at
# http://www.gnu.org/copyleft/gpl.html.
# 
# 
# CONTRIBUTION SUBMISSION POLICY:
# 
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of
# the GNU General Public License and is only of importance to you if
# you choose to contribute your changes and enhancements to the
# community by submitting them to Best Practical Solutions, LLC.)
# 
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with
# Request Tracker, to Best Practical Solutions, LLC, you confirm that
# you are the copyright holder for those contributions and you grant
# Best Practical Solutions,  LLC a nonexclusive, worldwide, irrevocable,
# royalty-free, perpetual, license to use, copy, create derivative
# works based on those contributions, and sublicense and distribute
# those contributions and any derivatives thereof.
# 
# END BPS TAGGED BLOCK }}}
package RT::Action::ReassignOwner;

use strict;
use base qw(RT::Action::Generic);

# version in RT::Extension::ReassignOwner

sub Describe  {
  my $self = shift;
  return (ref $self );
}

sub Prepare {
  return 1;
}

sub Commit {
    my $self = shift;

    my $Transaction = $self->TransactionObj;
    my $Ticket      = $self->TicketObj;
    my $Owner       = $Ticket->OwnerObj;

    $RT::Logger->debug('Setting owner of ticket ' . $Ticket->Id . ' to Nobody');
    my ($val,$msg) = $Ticket->SetOwner($RT::Nobody->id,'Force');
    unless ($val) {
        $RT::Logger->error("Error setting owner to Nobody - $msg");
        return 0;
    }

    $RT::Logger->debug('Adding owner ' . $Owner->Id . ' as AdminCc of ticket ' . $Ticket->Id);
    ($val, $msg) = $Ticket->AddWatcher( Type => 'AdminCc', PrincipalId => $Owner->PrincipalObj->Id );
    unless ($val) {
        $RT::Logger->error("Error adding owner as AdminCc - $msg");
        return 0;
    }

    return 1;
}

1;
