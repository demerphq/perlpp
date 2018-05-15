#!/usr/bin/env perl -W
# Testing perlpp with invalid input
use strict;
use warnings;
use Test::More;
use IPC::Run3;
use constant CMD => ($ENV{PERLPP_CMD} || 'perl -Iblib/lib blib/script/perlpp');
(my $whereami = __FILE__) =~ s/07-invalid\.t$//;
diag "perlpp command " . CMD . "; whereami $whereami.";

my ($out, $err);

my @testcases=(
	# [$in (the erroneous script), $err_re (stderr output, if any specific)]
	['<?= 2+ ?>', qr/syntax error/],
	['<?= "hello ?>', qr/string terminator '"'/],
	['<?= \'hello ?>', qr/string terminator "'"/],
	['<? my $foo=80 #missing semicolon' . "\n" .
		'?>#define QUUX (<?= $foo/40 ?>)', qr/syntax error/],
	['<? o@no!!! ?>'],
); #@testcases

# Tests of line numbers when there are errors in the input
my @testcases2 =(
	# [error RE, perlpp options...]
	[qr/multiline\.txt/, $whereami . 'multiline.txt'],
	[qr/error.*line 12/, $whereami . 'multiline.txt'],
	[qr/Number found.*line 13/, $whereami . 'multiline.txt'],

	# Tests with --Elines.  Note: the specific line numbers here may need
	# to be changed if the internals of perlpp change.  This is OK;
	# please just make sure to document the change and the reason in the
	# corresponding commit message.
	[qr/script.*-E/, '--Elines', $whereami . 'multiline.txt'],
	[qr/error.*line 47/, '--Elines', $whereami . 'multiline.txt'],
	[qr/Number found.*line 48/, '--Elines', $whereami . 'multiline.txt'],
);

plan tests =>
	scalar @testcases +
	scalar @testcases2;

for my $lrTest (@testcases) {
	my ($testin, $err_re) = @$lrTest;
	$err_re = qr/./ if(!defined $err_re);
		# by default, accept any stderr output as indicative of a failure
		# (a successful test case).

	run3 CMD, \$testin, \$out, \$err;
	like($err, $err_re);

} # foreach test

for my $lrTest (@testcases2) {
	my $err_re = shift @$lrTest;
	run3 join(' ', CMD, @$lrTest), \undef, \undef, \$err;
	like($err, $err_re);
}

# vi: set ts=4 sts=0 sw=4 noet ai: #
