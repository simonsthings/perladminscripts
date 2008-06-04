#!/usr/bin/perl -w
# 
# Task submission upload script.
# Written by Simon Vogt, November 2007
#
# This script scans a certain folder on the hard disk 
# for entries, lists them, and provides an upload field
# which students can use to upload their homework programs.
#
###################################################

use strict;
use CGI;
my $cgi = new CGI;
use CGI::Carp qw(fatalsToBrowser);

my $zetteluploadroot = "/var/www/zettelupload";
my $courseroot = "$zetteluploadroot/data";
my $scriptroot = "$zetteluploadroot/perlscript";

my $cmd;
my $cmdoutput;

my $coursename = $cgi->param('coursename');


print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>ISIP Task Submission</title></head><body bgcolor='#E0E0E0'>\n";
print "<h1><font color='red'>The submit deadline is over.</font></h1>\n";
print "The deadline for submission was at 12:00, 15.1.2007. <br>";
#print "If you could not sumbit because of technical problems, please contact vogt\@isip.uni-luebeck.de .";
print "<hr>";
print "</body></html>\n";
