# -*- tab-width: 4 -*-
###############################################
#
# $Id: C.pm,v 1.12 2013/04/12 15:01:08 ajlittoz Exp $
#
# Enhances the support for the C language over that provided by
# Generic.pm
#
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

package LXR::Lang::C;

$CVSID = '$Id: C.pm,v 1.12 2013/04/12 15:01:08 ajlittoz Exp $ ';

use strict;
use LXR::Common;
use LXR::Lang;
require LXR::Lang::Generic;

@LXR::Lang::C::ISA = ('LXR::Lang::Generic');

# Process a C/C++ include directive
sub processinclude {
	my ($self, $frag, $dir) = @_;

	my $source = $$frag;
	my $dirname;	# include directive name
	my $spacer;		# spacing
	my $file;		# language include file
	my $path;		# OS include file
	my $lsep;		# left separator
	my $rsep;		# right separator
	my $link;		# link to include file
	my $identdef = $self->langinfo('identdef');

	if ($source !~ s/^				# Parse instruction
				([\w\#]\s*[\w]*)	# reserved keyword for include construct
				(\s+)				# space
				(	(\")(.+?)(\")	# C syntax
				|	(\0<)(.+?)(\0>)	# C alternate syntax
				)
				//sx) {		# Parse directive
		# Guard against syntax error or unexpected variant
		# Advance past keyword, so that parsing may continue without loop.
		$source =~ s/^($identdef)//;	# Erase keyword
		$dirname = $1;
		$$frag =	"<span class='reserved'>$dirname</span>";
		&LXR::SimpleParse::requeuefrag($source);
		return;
	}
	$dirname = $1;
	$spacer  = $2;
	$lsep    = $4 . $7;
	$file    = $5 . $8;
	$path    = $file;
	$rsep    = $6 . $9;

	$link = $self->_linkincludedirs
				( &LXR::Common::incref
					($file, "include", $path, $dir)
				, $file
				, '/'
				, $path
				, $dir
				);

	$$frag =	"<span class='reserved'>$dirname</span>"
			.	$spacer
			.	$lsep
			.	$link
			.	$rsep;
}

1;
