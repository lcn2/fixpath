#!/usr/bin/perl -w0
#
# fixpath - fix pathnames by replacing bad chars with %xx sequences
#
# usage:
#
#	./fixpath [-n] [-v] dir
#
#	-n	do not rename anything
#	-v	verbose / debug
#
# @(#) $Revision: 1.1 $
# @(#) $Id: fixpath.pl,v 1.1 2001/10/26 14:52:45 chongo Exp $
# @(#) $Source: /usr/local/src/cmd/fixpath/RCS/fixpath.pl,v $
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
use File::Find;
use vars qw($opt_v $opt_n);
use Getopt::Std;


# version - RCS style *and* usable by MakeMaker
#
my $VERSION = substr q$Revision: 1.1 $, 10;
$VERSION =~ s/\s+$//;


# setup
#
MAIN: {

    # parse args
    #
    if (!getopts('vn') || ! defined $ARGV[0]) {
	die "usage: $0 [-n] [-v] dir ...\n";
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

	# only portable chars remain unescapted
	#
	if ($pset[$i] !~ m:[0-9A-Za-z.,_/-]:) {
	    $pset[$i] = sprintf("%%%02x", ord($pset[$i]));
	}
    }

    # recombine processed chars into the new path
    #
    $newpath = join('', @pset);

    # rename file
    #
    if ($newpath ne $path) {
	print "rename $path to $newpath\n" if defined $opt_v;
	if (! defined $opt_n) {
	    rename $path, $newpath or die "cannot rename $path $newpath: $!";
	}
    }
}
