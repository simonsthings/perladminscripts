#!/usr/bin/perl -w

use strict;
use CGI;
my $cgi = new CGI;
use CGI::Carp qw(fatalsToBrowser);

my $svnroot = "/srv/repositories/svn";
my $svnusersfilepath = "/etc/svn-users";
my $svndefaultfolders = "/var/www/sourcecode/svndefaultfolders";
my $cmd;
my $cmdoutput;
my $repositorycreationsuccess = "pending";
my $debug = 1;	# 1 = debug mode on, 0 = debug mode off

my @Feldnamen = $cgi->param();

print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>Project Creation...</title></head><body bgcolor=\"#E0E0E0\">\n";
print "<h1>Creating a new ISIP software project</h1>\n";

if ($debug)
{
	print "<h2>Listing Inputs...</h2>\n";
	print "<table border='1' CELLSPACING=0 CELLPADDING=5 bgcolor='white'><tr >";
	foreach my $Feld (@Feldnamen) 
	{
		print "<td valign='top'><b>$Feld: </b>";
		print "<pre>",$cgi->param($Feld),"</pre></td>";
	}
	print "</tr></table>";
}

my $NiceName = $cgi->param('NiceName');
my $UnixName = $cgi->param('UnixName');
my $ProjectDescription = $cgi->param('ProjectDescription');
my $OwnerName = $cgi->param('OwnerName');
my $InitialAccessRights = $cgi->param('InitialAccessRights');

# remove trailing spaces:
$UnixName =~ s/\s*$//g;		# should remove trailing spaces

#Creating Subversion repository:
print "<h2>Creating Subversion repository...</h2>\n";

	$cmd = "svnadmin create $svnroot/$UnixName";
	print "<code>$cmd</code><br>\n";
	$cmdoutput = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	print "<i><font color='gray'><pre>" . $cmdoutput . "</pre></font></i>\n";
	if ($?) 
	{
		print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';
		$repositorycreationsuccess = "false";  # perl has no boolean variables
	}
	else
	{
		$repositorycreationsuccess = "true";   # perl has no boolean variables
	}
	
	
#Importing the trunk, branches and tags folders:
if ($repositorycreationsuccess eq "true")
{
	print "<h2>Importing the trunk, branches and tags folders...</h2>\n";
	
	$NiceName =~ s/\r\n/\n/g;	# transform windows linebreaks into unix linebreaks
	$NiceName =~ s/\r/\n/g;		# transform     mac linebreaks into unix linebreaks
	$NiceName =~ s/\"/\\\"/g;	# transform " string delimiters into \" string delimiters 
	
	$ProjectDescription =~ s/\r\n/\n/g;	# transform windows linebreaks into unix linebreaks
	$ProjectDescription =~ s/\r/\n/g;	# transform     mac linebreaks into unix linebreaks
	$ProjectDescription =~ s/\"/\\\"/g;	# transform " string delimiters into \" string delimiters 

	$NiceName 	    =~ s/ü/ue/gi;	# transform german special characters into normal characters
	$NiceName           =~ s/ä/ae/gi;	# transform german special characters into normal characters
	$NiceName           =~ s/ö/oe/gi;	# transform german special characters into normal characters
	$NiceName           =~ s/ß/sz/gi;	# transform german special characters into normal characters
	$ProjectDescription =~ s/ü/ue/gi;	# transform german special characters into normal characters
	$ProjectDescription =~ s/ä/ae/gi;	# transform german special characters into normal characters
	$ProjectDescription =~ s/ö/oe/gi;	# transform german special characters into normal characters
	$ProjectDescription =~ s/ß/sz/gi;	# transform german special characters into normal characters

	$cmd = "svn import $svndefaultfolders file:///srv/repositories/svn/$UnixName --username \"ISIP Intranet Agent\" --message \"First commit of $NiceName:\n\n$ProjectDescription\" ";
	if ($debug) {print "<code>$cmd</code><br>\n";}
	$cmdoutput = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	print "<i><font color='gray'><pre>" . $cmdoutput . "</pre></font></i>\n";
	if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';}

	print "(This is done to follow <a href='http://svn.collab.net/repos/svn/trunk/doc/user/svn-best-practices.html'>subversion conventions</a>)<br>\n";
}

#Setting Initial Access Rights:
if ($repositorycreationsuccess eq "true")
{
	print "<h2>Setting Initial Access Rights...</h2>\n";
	open(FILE, ">>$svnusersfilepath");	# Open for appending
	print FILE "\n\n";
	print FILE "[$UnixName:/]\n";
	print FILE "$InitialAccessRights" ;
	print FILE "\n";
	close(FILE);

	print "<i><font color='gray'><pre>";
	print "[$UnixName:/]\n";
	print "$InitialAccessRights" ;
	print "</pre></font></i>\n";
	
	print "(If you wish to change the access rights later on, you will need to log on to auxus as root...)";
	
	
	
}

# Storing the project settings:
if ($repositorycreationsuccess eq "true")
{
	print "<h2>Storing the project settings...</h2>\n";
	if ($debug) {print "<i><font color='gray'><pre>Creating the file $svnroot/$UnixName/ISIPsettings.conf</pre></font></i>\n";}
	open(FILE, ">$svnroot/$UnixName/ISIPsettings.conf");	# Open for appending
	print FILE "#The LDAP name of the owner of this repository for future reference:\n";
	print FILE "#This file was automatically created by the ISIP Intranet Agent running on auxus. The owner's Name must be in line 3 and the project name must be in line 4. This is line 2.\n" ;
	print FILE "$OwnerName\n";
	print FILE "$NiceName\n";
	close(FILE);
	print "(Only the owner can delete the repository and change access rights via web interface)\n";
}

# Setting unix folder permissions:
if ($repositorycreationsuccess eq "true")
{
	print "<h2>Setting unix folder permissions...</h2>\n";
	$cmd = "chmod 770 $svnroot/$UnixName -R";
	if ($debug) {print "<code>$cmd</code><br>\n";}
	$cmdoutput = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	print "<i><font color='gray'><pre>" . $cmdoutput . "</pre></font></i>\n";
	if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';}
}

# Finishing off:
if ($repositorycreationsuccess eq "true")
{
print "<h2>Finished!</h2>\n";
print "You can now <b>browse</b> your new SVN repository at <a href='http://sourcecode/viewvc/$UnixName'>http://sourcecode/viewvc/$UnixName</a> <br>\n";
print "and you can <b>write to it</b> with an SVN client at <a href='http://sourcecode/svn/$UnixName'>http://sourcecode/svn/$UnixName</a>.<br>\n";
print "(You may need to wait 5 minutes before the new access rights come into effect)<br>\n";
print "For an introduction to Subversion, see <a href='http://en.wikipedia.org/wiki/Subversion_%28software%29'>http://en.wikipedia.org/wiki/Subversion_(software)</a>";
}
else
{
print "<h2>Creation Failed!</h2>\n";
print "Please read the screen output above to see why.<br>\n";
print "Press the BACK button in your browser and try again. :)<br>\n";
}

print "</body></html>\n";

