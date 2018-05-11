#!/usr/bin/env perl -W
# Some basic tests for perlpp
use strict;
use warnings;
use Test::More;
use IPC::Run3;
use Text::PerlPP;
# Ugly hack.  Find the perlpp binary we're testing.  TODO handle this a
# completely different way!
use constant CMD => "perl -I$Text::PerlPP::INCPATH " .
	(
		$ENV{PERLPP_FILENAME} ||
		(
			$Text::PerlPP::INCPATH =~ m{blib/lib} ?
			$Text::PerlPP::INCPATH =~ s{blib/lib\b.*}{blib/script/perlpp}r :
			'bin/perlpp'
		)
	);
diag "perlpp command: " . CMD;

my ($in, $out, $err);

my @testcases=(
	# [$in (the script), $out (expected output), $err (stderr output, if any)]
	['<?= 2+2 ?>', "4"],
	['<?= "hello" ?>', "hello"],
	['<? print "?>hello, world!\'"<?" ; ?>', 'hello, world!\'"'],
	['Foo <?= 2+2 ?> <? print "?>Howdy, "world!"  I\'m cool.<?"; ?> bar'."\n",
		'Foo 4 Howdy, "world!"  I\'m cool. bar'."\n"],
	['<?# This output file is tremendously boring. ?>',''],
	['<? my $x=42; #this is a comment?><?=$x?>','42'],
	['<?#ditto?>',''],
	['<? my $foo=80; ?>#define QUUX (<?= $foo/40 ?>)', '#define QUUX (2)'],
	['<? print (map { $_ . $_ . "\n" } qw(a b c d)); ?>',"aa\nbb\ncc\ndd\n"],
	['<?:macro print (map { $_ . $_ . "\n" } qw(a b c d)); ?>',"aa\nbb\ncc\ndd\n"],
); #@testcases

plan tests => scalar @testcases;

for my $lrTest (@testcases) {
	my ($testin, $refout, $referr) = @$lrTest;
	run3 CMD, \$testin, \$out, \$err;
	if(defined $refout) {
		is($out, $refout);
	}
	if(defined $referr) {
		is($err, $referr);
	}

} # foreach test

# vi: set ts=4 sts=0 sw=4 noet ai: #

