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
print "<h1>Select your name and file to upload...</h1>\n";


# Looking up contents of the courseroot directory
$cmd = "ls -1A $courseroot/";
my @allcourses = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};

# Chopping off the line breaks from all array elements (otherwise the comparison below will not work):
chomp(@allcourses);

# Checking if the given course actually exists on disk:
my $courseexists = "no";
foreach my $foundcourse (@allcourses) 
{
	#print "Comparing the $foundcourse course to $coursename.<br>";
	if ($foundcourse eq $coursename)
	{
		#print "$foundcourse and $coursename are equal!";
		$courseexists = "yes";
	}
}
if ($courseexists ne "yes")
{
	print "The course $coursename was not found.";
	print "</body></html>\n";
}
else
{
	# Leerzeichen escapen...
	my $coursenameesc = $coursename;
	$coursenameesc =~ s/\ /\\\ /g;
	
	# Looking up contents of the course's directory
	$cmd = "ls -1A $courseroot/$coursenameesc";
	my @allstudents = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};

	# Chopping off the line breaks from all array elements (otherwise the html source will look ugly):
	chomp(@allstudents);

	print "<form action='/tasksubmission/receivezipfile' method='post' enctype='multipart/form-data'>";
	print "    <table>";
	print "    <tr><td>Your Name:</td><td><select name='studentname' size='1' >";
	foreach my $outputline (@allstudents) 
	{
		print "        <option>$outputline</option>";
	}
	print "    </select></td></tr>";
	print "    <tr><td>Your PIN:</td> <td><input type='password' name='mypin'></td></tr>";
	print "    <tr><td>Your Zip File:</td> <td><input type='file' name='myfile' accept='text/*' maxlength='2097152'></td></tr>";
	print "    </table>";
	print "    Please mention the task sheet number in your zip file, e.g., \"&lt;yourname&gt;-tasksheet2.zip\". The only allowed characters for the file name are A-Z, a-z, 0-9 and - .<br>";
	print "    It has been noticed that the submission does not work with IE. If you have problems, try using Firefox with this page.<br>";
	# print "    <font color='red'> 12:00 Deadline has passed. This submission system will be closed at 14:00.</font><br>";
	print "    <input type='hidden' name='coursename' value='$coursename'><br>\n";
	print "    <input type='submit' value='Upload!'>\n";
	print "</form>";

	print "<hr>";

	print "</body></html>\n";

}
