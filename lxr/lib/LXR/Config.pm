# -*- tab-width: 4 -*-
###############################################
#
# $Id: Config.pm,v 1.57 2013/01/22 09:39:28 ajlittoz Exp $

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

#############################################################

=head1 Config module

This module contains the API to the configuration file.
It is responsible for reading the file, locating the
parameter group for the current source-tree and presenting
an abstract interface to the C<'variables'>.

=cut

package LXR::Config;

$CVSID = '$Id: Config.pm,v 1.57 2013/01/22 09:39:28 ajlittoz Exp $ ';

use strict;
use File::Path;

use LXR::Common;

require Exporter;

use vars qw($AUTOLOAD $confname);

$confname = 'lxr.conf';


=head2 C<new (@parms)>

Method C<new> creates a new configuration object.

=over

=item 1 C<@parms>

the paramaters I<array> (just passed to C<_initialize>

=back

=cut

sub new {
	my ($class, @parms) = @_;
	my $self = {};
	bless($self);
	if ($self->_initialize(@parms)) {
		return ($self);
	} else {
		return undef;
	}
}


=head2 C<emergency ()>

Method C<emergency> returns whatever can be retrieved from
the configuration file.

It is intended to allow editing user-friendly error message when
a catastrophic event occurred during initialisation.

=cut

sub emergency {
	my ($class, @parms) = @_;
	my $self = {};
	bless($self);
	$self->_initialize(@parms);
	return ($self);
}


=head2 C<readconfig ()>

Method C<readconfig> returns the content of the configuration
file as a list.

B<Note:>

=over

This method should only be used in cases when it is relevant to
make distinction between the different blocks (such as I<showconfig>
or the need to create links to other trees).
In all other circumstances, the configuration file should only be
accessed through the public methods.

=back

=cut

sub readconfig {
	my $self = shift;
	my $confpath = $$self{'confpath'};

	unless (open(CONFIG, $confpath)) {
		die("Couldn't open configuration file \"$confpath\".");
	}

	local ($/) = undef;
	my $config_contents = <CONFIG>;
	$config_contents =~ /(.*)/s;
	$config_contents = $1;    #untaint it
	my @config = eval("\n#line 1 \"configuration file\"\n" . $config_contents);
	die($@) if $@;

	return wantarray ? @config : $config[0];
}


=head2 C<readfile ($file)>

Function C<readfile> returns the content of the designated
file as a list of "words" ("words" are delimited by spaces).

=over

=item 1 C<$file>

a I<string> containing the file name, relative to the LXR root
directory or absolute

=back

B<Note:>

=over

This is not a "method", it is a standard function.
Its main goal is to provide an easy way to initialize the
configuration C<'variables'> by reading the set of values from
a text file.

=back

=cut

sub readfile {
	local ($/) = undef;    # Just in case; probably redundant.
	my $file = shift;
	my @data;

	open(INPUT, $file) || fatal("Config: cannot open $file\n");
	$file = <INPUT>;
	close(INPUT);

	@data = $file =~ /([^\s]+)/gs;

	return wantarray ? @data : $data[0];
}


=head2 C<_initialize ($url, $confpath)>

Internal method C<_initialize> does the real object initialization.

=over

=item 1 C<$url>

a I<string> containing the initial part of the URL
(truncated at the invoking script)

=item 1 C<$confpath>

a I<string> containing the path of the configuration file
(either relative to the LXR root directory or absolute)

=back

If C<$confpath> is not defined, use the internal C<$confname>.

If C<$url> is not defined, try to extract something meaningful
from the invoking URL.

=cut

sub _initialize {
	my ($self, $url, $confpath) = @_;
	my ($dir,  $arg);

	unless ($url) {
		$url = 'http://' . $ENV{'SERVER_NAME'} . ':' . $ENV{'SERVER_PORT'};
		$url =~ s/:80$//;
	}

	$url =~ s!^//!http://!;		# allow a shortened form in genxref
	$url =~ s!^http://([^/]*):443/!https://$1/!;
	$url =~ s!/*$!/!;			# append / if necessary

	unless ($confpath) {
		($confpath) = ($0 =~ /(.*?)[^\/]*$/);
		$confpath .= $confname;
	}

	unless (open(CONFIG, $confpath)) {
		die("Couldn't open configuration file \"$confpath\".");
	}

	$$self{'confpath'} = $confpath;

	local ($/) = undef;
	my $config_contents = <CONFIG>;
	$config_contents =~ /(.*)/s;
	$config_contents = $1;    #untaint it
	my @config = eval("\n#line 1 \"configuration file\"\n" . $config_contents);
	die($@) if $@;

		# Store the global parameter group
	if (scalar(@config) > 0) {
		%$self = (%$self, %{ $config[0] });
	}

#	Find the applicable parameter group
#	"Modern" identification is based on 'host_names' and 'virtroot'
#	parameters (which needs to spplit $url); "compatibility"
#	identification uses 'baseurl' and 'baseurl_aliases'.
#	The target id ends up in 'baseurl' in both cases.
	$url =~ m!(^.*?://[^/]+)!;	# host name and port used to access server
	my $host = $1;
		# To allow simultaneous Apache and lighttpd operation
		# on 2 different ports, remove port for identification
	$host =~ s/(:\d+|)$//;
	my $port = $1;
	my $script_path;
	if ($url) {
		($script_path = $url) =~ s!^.*?://[^/]*!!; # remove host and port
	} else {
		$script_path = $ENV{'SCRIPT_NAME'};
	}
	$script_path =~ s!/[^/]*$!!;	# path to script
	$script_path =~ s!^/*!/!;		# ensure a single starting /
	my $parmgroup = 0;
		# Test every parameter group in turn
CANDIDATE: foreach my $config (@config[1..$#config]) {
		$parmgroup++;				# next parameter group
		my @hostnames;
		# If no 'host_names' in the current parameter group,
		# revert to the the global 'host_names' already loaded
		# in $self.
		if (exists($config->{'host_names'})) {
			@hostnames = @{$config->{'host_names'}};
		} elsif (exists($self->{'host_names'})) {
			@hostnames = @{$self->{'host_names'}};
		};
		my $virtroot = $config->{'virtroot'};
		my $hits = $virtroot =~ s!/+$!!;	# ensure no ending /
		$hits += $virtroot =~ s!^/*!/!;		# and a single starting /
		if ($hits > 0) {
			$config->{'virtroot'} = $virtroot
		}
		if ('/' eq $virtroot) {				# special case: LXR at root
			$config->{'virtroot'} = '';		# make sure no trouble on relative links
		}
		if (scalar(@hostnames)>0) {
			foreach my $rt (@hostnames) {
				$rt =~ s!/*$!!;		# remove trailing /
				$rt =~ s!^//!http://!; # allow for a shortened form
		# To allow simultaneous Apache and lighttpd operation
		# on 2 different ports, remove port for identification
				$rt =~ s/:\d+$//;
				if	(	$host eq $rt
					&&	$script_path eq $virtroot
					) {
					$config->{'baseurl'} = $rt . $port . $script_path;
					%$self = (%$self, %$config);
					$$self{'parmgroupnr'} = $parmgroup;
					last CANDIDATE;
				}
			}
		} else { # elsif ($config->{'baseurl'}) {
		# To allow simultaneous Apache and lighttpd operation
		# on 2 different ports, remove port for identification
			$url =~ s/:\d+$//;
			my @aliases;
			if ($config->{'baseurl_aliases'}) {
				@aliases = @{ $config->{'baseurl_aliases'} };
			}
			my $root = $config->{'baseurl'};
			push @aliases, $root;
			foreach my $rt (@aliases) {
				$rt .= '/' unless $rt =~ m#/$#;    # append / if necessary
				$rt =~ s/:\d+$//;	# remove port (approximate match)
				my $r = quotemeta($rt);
				if ($url =~ /^$r/) {
					$rt =~ s/^$r/$rt$port/;
					$config->{'baseurl'} = $rt;
					%$self = (%$self, %$config);
					$$self{'parmgroupnr'} = $parmgroup;
					last CANDIDATE;
				}
			}
		}
	}

#	Have we found our target?
	if(!exists $self->{'baseurl'}) {
		$0 =~ m/([^\/]*)$/;
		if("genxref" ne $1) {
			return 0;
		} elsif($url =~ m!(https?:)?//.+!) {
			die "Can't find config for $url: make sure there is a 'host_names' + 'virtroot' combination or a 'baseurl' line that matches in lxr.conf\n";
		} else {
			# wasn't a url, so probably genxref with a bad --url parameter
			die "Can't find config for $url: " . 
			 	"the --url parameter should be a URL (e.g. http://example.com/lxr) and must match a baseurl line in lxr.conf\n";
		}
	}

	$$self{'encoding'} = "iso-8859-1" unless (exists $self->{'encoding'});

#	Final checks on the parsing dispatcher
	if (!exists $self->{'filetype'}) {
		if (exists $self->{'filetypeconf'}) {
			unless (open(FILETYPE, $self->{'filetypeconf'})) {
				die("Couldn't open configuration file ".$self->{'filetypeconf'});
			}
			local ($/) = undef;
			my $contents = <FILETYPE>;
			$contents =~ /(.*)/s;
			$contents = $1;    #untaint it
			my $mapping = eval("\n#line 1 \"file mappings\"\n" . $contents);
			die($@) if $@;
			if (defined($mapping)) {
				%$self = (%$self, %$mapping);
			}
		}
 	}
	if (!exists $self->{'filetype'}) {
		die "No file type mapping in $confpath.\n"
			. "Please specify 'filetype' or 'filetypeconf' \n";
	}
	if (!exists $self->{'interpreters'}) {
		die "No script interpreter mapping in $confpath.\n"
			. "Please specify 'interpreters' or 'filetypeconf' \n";
	}

	# Set-up various directories as necessary
	_ensuredirexists($self->{'tmpdir'});

#	See if there is ambiguity on the free-text search engine
	if (exists $self->{'glimpsebin'} && exists $self->{'swishbin'}) {
		die "Both Glimpse and Swish have been specified in $confpath.\n"
			."Please choose one of them by commenting out either glimpsebin or swishbin.\n";
		
	} elsif (exists $self->{'glimpsebin'}) {    
		if (!exists($self->{'glimpsedir'})) {
			die "Please specify glimpsedirbase or glimpsedir in $confpath\n"
				unless exists($self->{'glimpsedirbase'});
			$self->{'glimpsedir'} = $self->{'glimpsedirbase'} . $self->{'virtroot'};
		}
		_ensuredirexists($self->{'glimpsedir'});
	} elsif (exists $self->{'swishbin'}) {    
		if (!exists($self->{'swishdir'})) {
			die "Please specify swishdirbase or swishdir in $confpath\n"
				unless exists($self->{'swishdirbase'});
			$self->{'swishdir'} = $self->{'swishdirbase'} . $self->{'virtroot'};
		}
		_ensuredirexists($self->{'swishdir'});
	} else {
	# Since free-text search is not operational with VCSes,
	# don't complain if not configured.
	die	"Neither Glimpse nor Swish have been specified in $confpath.\n"
		."Please choose one of them by specifing a value for either glimpsebin or swishbin.\n"
		unless $self->{'sourceroot'} =~ m!^[^/]+:! ;
	}
	return 1;
}


=head2 C<treeurl ($group, $global)>

Method C<treeurl> returns an URL for the tree described by
parameter group C<$group>.
This URL tries to match the present hostname used to invoke LXR.

=over

=item 1 C<$group>

a I<reference> to the tree-specific parameter group

=item 1 C<$global>

a I<reference>to the global parameter group to provide default values
for parameters not present in the tree-specific group

=back

=head3 Algorithm

Parameters C<'host_names'> and C<'virtroot'> are retrieved to build
an URL to launch LXR on that tree.

It compares the hosts (in a list composed of C<'host_names'> from
the tree-specific or global parameter group) + C<'virtroot'> to
C<'script_path'> (with the script name removed).

If a match is found, C<undef> is returned, meaning that an
HTML-relative URL may be used.

If no match, a second attempt is made with the hosts only to test
for a target tree different from the current one.

If a host matches, an HTML-absolute URL is returned.

Otherwise, the first hostname in the list is selected for the returned
HTML-absolute URL.

B<Potential problems:>

=over

=item 1 Presently, only parameter C<'hostnames'> is used
because the automatic configurator does not use C<'baseurl'>
nor C<'baseurl_aliases'>, which are deprecated.

If file I<lxr.conf> is C<'baseurl'> based, the returned URL will
contain garbage.

=item 1 The LXR server may be accessed simultaneously under different names,
e.g. C<localhost> on the computer, a short name on the LAN and a full
URL from the Net.

Choosing the first name in C<'host_names'> may not give the correct name
for the current user (C<localhost> instead of a fully qualified URL).
But extracting the hostname from the page URL is not guaranteed to
be the correct choice in all circumstances.

This might be solved with a more complex structure in C<'host_names'>
made of 2 lists, one for "local" mode, the other for "remote" mode.
But, once again, how to chose reliably and automatically the correct
option?

With these two lists, an approach could be to note the index of the
hostname for the successfully identified trees.
If it is always the same, then determine if this is a local or remote
hostname and use the first hostname in the corresponding list for
the unknown tree.

=back

=cut

sub treeurl {
	my ($self, $group, $global) = @_;

	my ($accesshost, $accessport) =
		$HTTP->{'script_path'} =~ m!(^.+?://[^/:]+)(:\d+)?!;
	(my $scriptpath = $HTTP->{'script_path'}) =~ s!(^.+?://[^/:]+)(:\d+)?!$1!;
	my @hosts = @{$group->{'host_names'} || $global->{'host_names'}};
	my $virtroot =  $group->{'virtroot'};
	my $url;
	my $port;
	for my $hostname (@hosts) {
		$hostname =~ s!/*$!!;		# remove trailing /
		$hostname =~ s/(:\d+)$//;	# remove port
		my $port = $1;
	# Add http: if it was dropped in the hostname
		if ($hostname !~ m!^.+?://!) {
			$hostname = "http:" . $hostname;
		}
		$url = $hostname . $virtroot;
	# Is this the presently used hostname?
		last if $url eq $scriptpath;
		$url = undef;
	}
	# The current tree has been found, tell the caller
	return undef if defined($url);

	# This is an alternate tree, try to see if the current hostname
	# is on the list for this tree
	$url = undef;
	for my $hostname (@hosts) {
		$hostname =~ s!/*$!!;		# remove trailing /
		$hostname =~ s/(:\d+)$//;	# remove port
		$port = $1;
	# Add http: if it was dropped in the hostname
		if ($hostname !~ m!^.+?://!) {
			$hostname = "http:" . $hostname;
		}
		if ($hostname eq $accesshost) {
			$url = $hostname;
			last;
		}
	}
	# The current hostname is not on the list for this tree.
	# Take the first name but NOTE it is not reliable
	if (!defined($url)) {
		$url = $group->{'host_names'}[0]
			|| $global->{'host_names'}[0];
		$url =~ s/(:\d+)$//;
		$port = $1;
	}
	# If a port is given on 'host_names', use it.
	# Otherwise, use the incoming request port
	$url .= $port || $accessport;
	$url = "http:" . $url unless ($url =~ m!^.+?://!);
	return $url . $virtroot;
}


=head2 C<allvariables ()>

Method C<allvariables> returns the list of all defined variables.

=cut

sub allvariables {
	my $self = shift;

	return keys(%{ $self->{'variables'} || {} });
}


=head2 C<variable ($var, $val)>

Method C<variable> returns the current value of the designated variable.

=over

=item 1 C<$var>

a I<string> containing the name of the variable

=item 1 C<$val>

optional value; if present, replaces the current value

=back

If no current value has already been set, the default value is returned.

=cut

sub variable {
	my ($self, $var, $val) = @_;

	$self->{'variables'}{$var}{'value'} = $val if defined($val);
	return $self->{'variables'}{$var}{'value'}
	  || $self->vardefault($var);
}


=head2 C<vardefault ($var)>

Method C<variable> returns the default value of the designated variable.

=over

=item 1 C<$var>

a I<string> containing the name of the variable

=back

If no default value has been defined, the first value in C<'range'>
is returned.

=cut

sub vardefault {
	my ($self, $var) = @_;

	if (exists($self->{'variables'}{$var}{'default'})) {
		return $self->{'variables'}{$var}{'default'}
	}
	if (ref($self->{'variables'}{$var}{'range'}) eq "CODE") {
		my @vr = varrange($var);
		return $vr[0] if scalar(@vr)>0; return "head"
	}
	return	$self->{'variables'}{$var}{'range'}[0];
}


=head2 C<vardefault ($var, $val)>

Method C<variable> returns the description of the designated variable.

=over

=item 1 C<$var>

a I<string> containing the name of the variable

=item 1 C<$val>

optional value; if present, replaces the description

=back

B<Note:>

=over

Don't be confused! The word "description" is human semantic meaning
for this data. It is stored in the C<'data'> element of the hash
representing the variable and its state.

=back

=cut

sub vardescription {
	my ($self, $var, $val) = @_;

	$self->{'variables'}{$var}{'name'} = $val if defined($val);

	return $self->{'variables'}{$var}{'name'};
}


=head2 C<varrange ($var)>

Method C<variable> returns the set of values of the designated variable.

=over

=item 1 C<$var>

a I<string> containing the name of the variable

=back

=cut

sub varrange {
	my ($self, $var) = @_;
no strict "refs";
	if (ref($self->{'variables'}{$var}{'range'}) eq "CODE") {
		return &{ $self->{'variables'}{$var}{'range'} };
	}

	return @{ $self->{'variables'}{$var}{'range'} || [] };
}


=head2 C<varexpand ($exp)>

Method C<variable> returns its argument with all occurrences of
C<$xxx> replaced by the current value of variable C<'xxx'>.

=over

=item 1 C<$exp>

a I<string> to expand

=back

=cut

sub varexpand {
	my ($self, $exp) = @_;
	$exp =~ s/\$\{?([a-zA-Z]\w*)\}?/$self->variable($1)/ge;

	return $exp;
}


=head2 C<value ($var)>

Method C<variable> returns the value of a configuration parameter
with occurrences of C<$xxx> replaced by the current value of
variable C<'xxx'>.

=over

=item 1 C<$var>

a I<string> containing the configuration parameter name

=back

=cut

sub value {
	my ($self, $var) = @_;

	if (exists($self->{$var})) {
		my $val = $self->{$var};

		if (ref($val) eq 'ARRAY') {
			return map { $self->varexpand($_) } @$val;
		} elsif (ref($val) eq 'CODE') {
			return $val;
		} else {
			return $self->varexpand($val);
		}
	} else {
		return undef;
	}
}


=head2 C<AUTOLOAD (@parms)>

Magical Perl method C<AUTOLOAD> to instantiate unknown barewords.

=over

=item 1 C<@parms>

optional arguments I<array> passed to instantiated function

=back

When a bareword is encountered in a construct like C<$config->bareword>,
this method is called. It tries to get the expanded value of
configuration parameter C<'bareword'> with method C<value>.
If the value itself is a function, that function is called with
the parameters provided to C<bareword>.

The final value is returned to the caller.

=cut

sub AUTOLOAD {
	my $self = shift;
	(my $var = $AUTOLOAD) =~ s/.*:://;

	my @val = $self->value($var);

	if (ref($val[0]) eq 'CODE') {
		return $val[0]->(@_);
	} else {
		return wantarray ? @val : $val[0];
	}
}


=head2 C<mappath ($path, @args)>

Method C<mappath> returns its argument path transformed by
the C'maps'> rules.

=over

=item 1 C<$path>

a I<string> containing the path to transform

=item 1 C<@args>

an I<array> containing strings of the form var=value forcing
a context in which the C<'maps'> rules are applied

=back

B<Note:>

=over

The rules are applied once only in the path.
Should they be globally applied (with flag C<g> on the regexp)?
Does this make sense?

=back

=cut

sub mappath {
	my ($self, $path, @args) = @_;
	return $path if !exists($self->{'maps'});
	my %oldvars;
	my ($m, $n);

	# Protect the current context
	foreach $m (@args) {
		if ($m =~ /(.*?)=(.*)/) {
			$oldvars{$1} = $self->variable($1);
			$self->variable($1, $2);
		}
	}

	my $i = 0;
	while ($i < @{$self->{'maps'}}) {
		$m = ${$self->{'maps'}}[$i++];
		$n = ${$self->{'maps'}}[$i++];
 		$path =~ s/$m/$self->varexpand($n)/e;
	}

	# Restore the initial context
	while (($m, $n) = each %oldvars) {
		$self->variable($m, $n);
	}

	return $path;
}


=head2 C<unmappath ($path, @args)>

Method C<unmappath> attempts to undo the effects of C<mappath>.
It returns an abstract path suitable for a new processing by
C<mappath> with a new set of variables values.

=over

=item 1 C<$path>

a I<string> containing the file path to "invert".

=item 1 C<@args>

an I<array> containing strings of the form var=value defining
the context in which the C<'maps'> rules were applied.

=back

=head3 Algorithm

C<'maps'> rules are given as I<pattern> C<=E<gt> > I<replacement>
where I<replacement> may itself contain C<$I<var> > markers
asking for substitution by the designated variable value.

Tentatively I<inverting> C<mappath> processing means applying
"inverse" C<'maps'> rules in reverse order.

B<Note:>

=over

=item

From a theoretical point of view, this problem has no general
solution. It can be solved only under restrictive conditions,
i.e. information has not been irremediably lost after rule
application (consider what happens if you completely remove
a path fragment and its delimiter).

=back

The generated "inverted" rule has the following form:

transformed I<replacement> C<=E<gt> > transformed I<pattern>

=over

=item 1 transformed I<replacement>

=over

=item 1 C<$num> elements become C<.+?>, i.e. "match something, but not
too much" to avoid to "swallow" what is described after this
sub-pattern.

B<Note:>

=over

=item

It could be possible to be more specific through parsing this
original pattern and analysing the associated parenthesised
sequence.
However, this could be time-expensive and the final advantage
might not be worth the trouble.
Even the known C<'maps'> rules for kernel cross-referencing
do not use C<$num>.

=back

=item 1 C<$var> are replaced by the designated variable value.

=item 1 If the original pattern had C<^> (start) or C<$> (end)
position anchors, these are transfered.

=back

=item 1 transformed I<pattern>

=over

=item 1 Optional quantifiers C<?> or C<*> (and variants
suffixed with C<?> or C<+>)

If there is one, process the sequence from beginning to the
quantifier to remove the preceding C<(> C<)> parenthesised
block (proceeding carefully from innermost pair of parenthesis
to outermost), C<[> C<]> character range or single character.

B<Caveat:>

=over

=item

When a character is checked, care is taken to cope with
C<\>-I<escaped> characters but no effort is done to manage
longer escape sequences such as C<\000>, C<\x00> or any other
multi-character sequence.
Consequently, the above transformation WILL FAIL if any such
sequence is present in the original pattern.

=back

I<The sub-pattern is entirely removed because the corresponding
string can be omitted from the file path. We then do not bother
with creating a sensible string since it is optional.>

=item 1 Repeating quantifier C<+> (and variants
suffixed with C<?> or C<+>)

Quantifier is merely removed to leave a single occurrence of
the matching string.

=item 1 C<(> C<)> groups

Proceeding from innermost group to outermost, the first alternative
is kept and the others deleted. The parentheses, now useless
and, matter of fact, harmful, are erased.

=item 1 C<[> C<]> character ranges

Only the first character is kept.

I<If the specification is an exclusion range C<[^ E<hellip> ]>,
the range is replaced by character C<%>, without further parsing,
in the hope it does not appear in the range.>

=item 1 C<\> escaped characters

Depending on the character, the sequence is erased, replaced by
a conventional character (think of character classes) or by the
designator letter without the backslash.

B<Caveat:>

=over

=item

No effort is done to manage longer escape sequences such as
C<\000>, C<\x00> or any other multi-character sequence on the
ground that this escape sequence is also valid in the replacement
part of an C<s///> instruction.

However some multi-character sequences (e.g. C<\P>) are not valid
and will ruin the "inverse" rule but they are thought to be rather
rare in LXR context.

=back

=back

=back

The generated rule is then applied to C<$path>.

The effect is cumulated on all "inverse" rules and the final
C<$path> is returned as the value of this C<sub>.

=cut

sub unmappath {
	my ($self, $path, @args) = @_;
	return $path if	(!exists($self->{'maps'})
					|| scalar($self->allvariables)<2
					);
	my ($m, $n);
	my %oldvars;

#	Save current environment before switching to @args environment
	foreach $m (@args) {
		if ($m =~ /(.*?)=(.*)/) {
			$oldvars{$1} = $self->variable($1);
			$self->variable($1, $2);
		}
	}

	my $i = $#{$self->{'maps'}};
	while ($i >= 0) {
		$n = ${$self->{'maps'}}[$i--];
		$m = ${$self->{'maps'}}[$i--];
# 		if ($n =~ m/\$\{?[0-9]/) {
# 			warning("Unable to reverse 'maps' rule $m => $n");
# 		}
	# Transform the original "replacement" into a pattern
	#	Replace variable markers by their values
		$n = $self->varexpand($n);
	#	Use a generic sub-pattern for $number substitutions
		$n =~ s/\$\{?[0-9]+\}?/.+?/g;

	# Next transform the original "pattern" into a replacement
	#	Remove x* or x? fragments since they are optional
		$m =~ s/((?:\\.|[^*?])+)[*?][+?]?/{
			my $pre = $1;
	#	( ... ) sub-pattern
			if ($pre =~ m!(\\.|[^\\])\)$!) {
	#	a- remove innermost ( ... ) blocks
				while ($pre =~ s!((?:^|\\.|[^\\])\((?:\\.|[^\(\)])*)\((?:\\.|[^\(\)])*\)!$1!) {};
	# 			                 1                ^                1 ^                 ^
	#	b- remove outer ( ... ) block
				$pre =~ s!(^|\\.|[^\\])\((?:\\.|[^\)])*\)$!$1!;
	#	[ ... ] sub-pattern
			} elsif ($pre =~ m!(\\.|[^\\])\]$!) {
				$pre =~ s!(^|\\.|[^\\])\[(?:\\.|[^\]])+\]$!$1!;
	#	single character or class
			} else {
				$pre =~ s!\\?.$!!;
			}
			$pre;
		}/ge;
		$m =~ s!(^|[^\\])\(\)!$1!;
	#	Remove + quantifiers since a single occurrence is enough
		$m =~ s/(\\.|[^+])\+[+?]?/$1/g;
	#	Process block constructs
	#	( ... ) sub-pattern: replace by first alternative
		while ($m =~ m!(^|\\.|[^\\])\(!) {
	#	a- process innermost, i.e. non-nested, ( ... ) blocks
			while ($m =~ s!((?:^|\\.|[^\\])\((?:\\.|[^\(\)])*)\(((?:\\.|[^\(\)\|])+)\|?(?:\\.|[^\(\)])*\)!$1$2!) {};
		#	               1                ^                1 ^2                  2                    ^
	#	b- process the remaining outer ( ... ) block
			$m =~ s!(^|\\.|[^\\])\(((?:\\.|[^\)\|])+)(?:\|(?:\\.|[^\(\)])*)?\)!$1$2!;
#			        1           1 ^2                2                        ^
		}
	#	[ ... ] sub-pattern: replace by one character
		$m =~ s!(^|\\.|[^\\])\[(\\.|[^\]])(?:\\.|[^\\])*\]!
			# Heuristic attempt to handle [^range]
			if ($2 eq "^") {
				$2 = "%";
			}
			$1 . $2;
				!ge;
	#	\x escaped character
	# NOTE: not handled g k N p P X o x
		$m =~ s!\\[AbBCEGKlLQuUzZ]!!g;
		$m =~ s!\\w!A!g;
		$m =~ s!\\d!0!g;
		$m =~ s!\\D!=!g;
		$m =~ s!\\W!&!g;
		$m =~ s!\\[hs]! !g;
		$m =~ s!\\([HNSV])!$1!g;
		$m =~ s!\\v!\n!g;
		$m =~ s!\\([^0-9abcdefghklnoprstuvwxzABCDEGHKLNPQRSUVWXZ])!$1!g;

	# Finally, transfer position information from original pattern
	# to new pattern (i.e. start and end tags)
		$n = "^" . $n if $m =~ s/^\^//;
		$n .= "\$" if $m =~ s/\$$//;

	# Apply the generated rule
		$path =~ s/$n/$m/;
	}

#	Restore original environment
	while (($m, $n) = each %oldvars) {
		$self->variable($m, $n);
	}

	return $path;
}


=head2 C<_ensuredirexists ($chkdir)>

Internal function C<_ensuredirexists> checks that directory C<$dir> exists
and creates it if not in a way similar to "C<mkdir -p>".

=over

=item 1 C<$chkdir>

a I<string> containing the directory path.

=back

=head3 Algorithm

Every component of the path is checked from left to right.
Both OS-absolute or relative paths are accepted, though the
latter form would probably not make sense in LXR context.

=cut

sub _ensuredirexists {
	my $chkdir = shift;
	my $dir;
	while ($chkdir =~ s:(^/?[^/]+)::) {
		$dir .= $1;
		if(!-d $dir) {
			mkpath($dir)
			or die "Couldn't make the directory $dir: ?!";
			chmod 0777, $dir;
		}
	}  
}


1;
