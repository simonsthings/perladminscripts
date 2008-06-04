#!/usr/bin/perl -w


use strict;           # Make us need to declare each variable for easier error tracking
use CGI;              # Use GCI interface (as found in some examples on the internet)
my $cgi = new CGI;
use CGI::Carp qw(fatalsToBrowser);   # I guess this sends any error messages to the browser.

# declare my variables:
my $svnroot = "/srv/svn/repos";
my $tracroot = "/srv/trac";
my $cmd;
my $cmdoutput;

# send web page header to browser:
print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>Start Trac and SVN server</title></head><body bgcolor='#E0E0E0'>\n";
print "<h1>Start a Trac or SVN server</h1>\n";

## The deactivated code in the following section was for debugging:

# print "<h2>Listing repositories...</h2>\n";
	$cmd = "ls -1A $svnroot/";    # define unix shell command to execute
#	print "<code>$cmd</code><br>\n";
	my @svnrepos = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
#	print "<i><font color='gray'><pre>";
#	foreach my $outputline (@svnrepos) 
#	{
#		print $outputline ;
#	}
#	print "</pre></font></i>\n";
	if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};

#print "<h2>Listing trac projects...</h2>\n";
	$cmd = "ls -1A $tracroot/";   # define unix shell command to execute
#	print "<code>$cmd</code><br>\n";
	my @tracproj = `$cmd 2>&1`;  # The 2>&1 makes all screen output (standard + errors) be written to the web page.
#	print "<i><font color='gray'><pre>";
#	foreach my $outputline (@tracproj) 
#	{
#		print $outputline ;
#	}
#	print "</pre></font></i>\n";
	if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};

print "<b>Please choose one of these svn+trac projects to serve:</b><br>\n";
	my @commonprojects;
	foreach my $svnrep (@svnrepos) 
	{
		foreach my $tracpro (@tracproj) 
		{
			if ($svnrep eq $tracpro)
			{
				@commonprojects = (@commonprojects , $svnrep);
			}
		}
	}
#	print "<i><font color='gray'><pre>";
#	foreach my $outputline (@commonprojects) 
#	{
#		print $outputline ;
#	}
#	print "</pre></font></i>\n";


print "<br><form action='/cgi-bin/doserverstart.pl' method='get'>";
print "    Project:<br> <select name='projectunixname' size='1' >";
foreach my $outputline (@commonprojects) 
{
	print "        <option>$outputline</option>";
}
print "    </select><br>";
print "    SVNServe Port (default=3690):<br> <input type='text' name='svnport' size='5' value='7000'><br>";
print "    Trac daemon Port:<br> <input type='text' name='tracdport' size='5' value='8000'><br><br>";
print "    <input type='submit' value='Start Stand-alone Servers'>";
print "</form>";

print "<hr>\n";
$cmd = "ps -A | grep svnserve";
print "$cmd <br>\n";
print "<i><font color='gray'><pre>";
	print `$cmd 2>&1` ."<br>\n";   # The 2>&1 makes all screen output be written to the web page.
print "</pre></font></i>\n";

$cmd = "ps -A | grep tracd";
print "$cmd <br>\n";
print "<i><font color='gray'><pre>";
	print `$cmd 2>&1` ."<br>\n";   # The 2>&1 makes all screen output be written to the web page.
print "</pre></font></i>\n";

print "<hr>";
print "This installation of XAMPP and SVN don't work together because they \"are linked to different versions of apr and apr-utils\". We'd have to recompile apache and I don't want to do that. So your best bet is to use the stand-alone servers.<br>\n";

print "</body></html>\n";

