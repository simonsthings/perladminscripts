#!/usr/bin/perl -w
# 
# Simple plaintext password creator for low-security user authentication.
# Written by Simon Vogt, November 2007
#
# Based on my script taskupload.pl
#
###################################################

use strict;
#use CGI;
#my $cgi = new CGI;
#use CGI::Carp qw(fatalsToBrowser);

my $zetteluploadroot = "/var/www/zettelupload";
my $courseroot = "$zetteluploadroot/data";
my $scriptroot = "$zetteluploadroot/perlscript";

my $cmd;
my $cmdoutput;

# change this for new courses!
my $coursename = "DSP for BME";
my $passwordlength = 8 ;

#print "Content-type: text/html\n\n";
#print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
#print "<html><head><title>Start Trac and SVN server</title></head><body bgcolor='#E0E0E0'>\n";
#print "<h1>Start a Trac or SVN server</h1>\n";


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
	#print "</body></html>\n";
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

	print "All students:\n@allstudents";
	
	# Open file for writing:
	print "\n\nOpening \"".$coursename.".htpasswd\" for writing.\n";
	open DAT,'>'.$coursename.'.htpasswd' or die 'Error dealing with output file: ',$!;

	# Write names to file with random passwords:
	my $minimum = 10 ** ($passwordlength-1);  # we want random numbers with constant number of digits
	my $range = $minimum * 9;                 # we want random numbers with constant number of digits
	my $randnumb;
	foreach my $student (@allstudents)
	{
		$randnumb = int(rand($range)) + $minimum;
		print DAT $student . ":$randnumb\n" ;
	}
	close DAT; # Close output file
	
	print "Finished writing cleartext password file.\n";
	
	print "Changing ownership for webserver.\n";
	print `chown www-data.www-data $coursenameesc.htpasswd`;
	
	print "Ok. the file should now exist, with random numbers as passwords.\n\n"
}


