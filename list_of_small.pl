#!/usr/bin/perl -w

#########################################################################
### List of small size file                                             
###                                                                     
### Copyright (C) 2014 Stanislav Vastyl (stanislav@vastyl.cz)
###
### This program is free software: you can redistribute it and/or modify
### it under the terms of the GNU General Public License as published by
### the Free Software Foundation, either version 3 of the License, or
### any later version.
###
### This program is distributed in the hope that it will be useful,
### but WITHOUT ANY WARRANTY; without even the implied warranty of
### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
### GNU General Public License for more details.
###
### You should have received a copy of the GNU General Public License
### along with this program. If not, see <http://www.gnu.org/licenses/>.
#########################################################################

use strict;
use warnings;

### mail settings
my $to = 'dataprotector@vsb.cz';
my $from = 'jelen';
my $subject = 'Homen - count small files';

### list of directory root
my $root = "/";
opendir my $dh, $root or die "$0: opendir: $!";
my @dirs = grep {-d "$root/$_" && ! /^\.{1,2}$/} readdir($dh);

my @result = ();
### sum files of dir
my $sum_cf = 0;
my $sum_csf = 0;
foreach my $item (@dirs) {
	my $percent = 0;
	my $csf =`find $root$item -type f -size -1024c |wc -l 2>/dev/null`;
	my $cf = `find $root$item  -type f |wc -l 2>/dev/null`;
	chomp($csf); chomp($cf);
	$sum_cf = $sum_cf + $cf;
	$sum_csf = $sum_csf + $csf;
	if ($csf != 0){
		$percent = int(($csf / $cf) * 100);
	} 
	push(@result, "In directory $root$item is $csf small files and total files is $cf = $percent %\n");
	
}

open MAIL, "|/usr/sbin/sendmail -t";

### Mail Header
print MAIL "To: $to\n";
print MAIL "From: $from\n";
print MAIL "Subject: $subject\n\n";
### Mail Body
print MAIL "RESULT of small files in server\n";
print MAIL "-------------------------------\n";
print MAIL @result;
print MAIL "\n";
print MAIL "Total files is: $sum_cf \n";
print MAIL "Total small files is: $sum_csf \n";
my $sum_percent = 0;
if ($sum_csf != 0){
	$sum_percent = int(($sum_csf / $sum_cf) * 100);
}
print MAIL "Total average is: $sum_percent %";

close MAIL;