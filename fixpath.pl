#!/usr/bin/perl -w0
#
# fixpath - fix pathnames by replacing bad chars with %xx sequences
#
# usage:
#
#	./fixpath [-n] [-v] [-s] [-i] dir
#
# @(#) $Revision: 1.7 $
# @(#) $Id: fixpath.pl,v 1.7 2004/05/21 15:19:59 chongo Exp $
# @(#) $Source: /usr/local/src/bin/fixpath/RCS/fixpath.pl,v $
#
# Copyright (c) 2001 by Landon Curt Noll.  All Rights Reserved.
#
# Permission to use, copy, modify, and distribute this software and
# its documentation for any purpose and without fee is hereby granted,
# provided that the above copyright, this permission notice and text
# this comment, and the disclaimer below appear in all of the following:
#
#       supporting documentation
#       source copies
#       source works derived from this source
#       binaries derived from this source or from derived source
#
# LANDON CURT NOLL DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
# INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
# EVENT SHALL LANDON CURT NOLL BE LIABLE FOR ANY SPECIAL, INDIRECT OR
# CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
# USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# chongo <was here> /\oo/\
#
# Share and enjoy!

# requirements
#
use strict;
use bytes;
use File::Find;
use vars qw($opt_v $opt_n $opt_s $opt_i);
use Getopt::Std;


# version - RCS style *and* usable by MakeMaker
#
my $VERSION = substr q$Revision: 1.7 $, 10;
$VERSION =~ s/\s+$//;


# setup
#
MAIN: {

    # parse args
    #
    if (!getopts('vnsi') || ! defined $ARGV[0]) {
	die "usage: $0 [-n] [-v] [-s] [-i] dir ...\n" .
	    "\n" .
	    "\t-n\tdo not rename anything\n" .
	    "\t-v\tverbose / debug\n" .
	    "\t-s\tstrict POSIX chars only\n" .
	    "\t-i\tignore \%'s if followed by 2 hex chars\n";
    }

    # process lines
    #
    finddepth(\&fixfile, @ARGV);
}

# fixfile - fix a file or directory processed by finddepth
#
sub fixfile
{
    my $path = $_;	# current filename
    my $newpath;	# new nul terminated path
    my @pset;		# $path split into individual chars
    my $i;
    
    # split the path into single chars
    #
    @pset = split(//, $path);

    # process each char
    #
    for ($i=0; $i <= $#pset; ++$i) {

	# ignore %'s if -i
	#
	if (defined $opt_i && $pset[$i] =~ /%/) {
	    if ($pset[$i+1] =~ /[0-9a-fA-F]/ && $pset[$i+2] =~ /[0-9a-fA-F]/) {
	        next;
	    }
	}

	# only safe/portable chars remain unescapted
	#
	if (defined $opt_s) {
	    # only POSIX portable chars
	    if ($pset[$i] !~ m|[0-9A-Za-z.,_/-]|) {
		$pset[$i] = sprintf("%%%02x", ord($pset[$i]));
	    }
	} elsif ($i == 0) {
	    # less strict, but avoid problem first file chars
	    if ($pset[$i] !~ m|[0-9A-Za-z.,_/@^!:]|) {
		$pset[$i] = sprintf("%%%02x", ord($pset[$i]));
	    }
	} else {
	    # less strict on remaining file chars
	    if ($pset[$i] !~ m|[0-9A-Za-z.,_/@^!+:~!=-]|) {
		$pset[$i] = sprintf("%%%02x", ord($pset[$i]));
	    }
	}
    }

    # recombine processed chars into the new path
    #
    $newpath = join('', @pset);

    # rename file
    #
    if ($newpath ne $path) {
	if (defined $opt_v) {
	    my $dir = "$File::Find::dir";
	    print "mv -f $dir/$path\t$dir/$newpath\n"
	}
	if (! defined $opt_n) {
	    rename $path, $newpath or die "cannot rename $path $newpath: $!";
	}
    }
}
