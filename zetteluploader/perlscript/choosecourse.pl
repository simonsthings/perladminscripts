#!/usr/bin/perl -w

use strict;
use CGI;
my $cgi = new CGI;
use CGI::Carp qw(fatalsToBrowser);

my $courseroot = "/var/www/zettelupload/data";

my $svnroot = "/srv/svn/repos";
my $tracroot = "/srv/trac";
my $cmd;
my $cmdoutput;


print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>ISIP Task Submission</title></head><body bgcolor='#E0E0E0'>\n";
print "<h1>Choose your course</h1>\n";


$cmd = "ls -1A $courseroot/";
my @allcourses = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};

# Chopping off the line breaks from all array elements (otherwise the comparison below will not work):
chomp(@allcourses);


print "<form action='/tasksubmission/taskupload' method='post'>\n";
print "    <select name='coursename' size='1' >\n";
foreach my $outputline (@allcourses) 
{
	print "        <option>$outputline</option>\n";
}
print "    </select>\n";
print "    <input type='submit' value='Enter Submission page!'>\n";
print "</form>\n";

print "</body></html>\n";

