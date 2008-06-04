#!/usr/bin/perl -w

use strict;
use CGI; # Modul fuer CGI-Programme

my $cgi = new CGI; # neues Objekt erstellen

my $courseroot = "/var/www/inventury/items";
my $maxfilenamelength = 40;
my @extensions = qw(zip);

# Get the folder name of the Inventury Item:
my $itemfoldername = $cgi->param('itemfoldername');





# Send HTML header to browser:
print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>Viewing Inventury Item '$itemfoldername'</title></head><body bgcolor='#E0E0E0'>\n";
print "<h1>Inventury Item '$itemfoldername'</h1>\n";



my $cmd;
my $cmdreturn;
my $fpath;
my $fname;
my @allfiles;
my @allstudents;
if ($continue eq "true")
{

	# Leerzeichen escapen...
	my $coursenameesc = $coursename;
	$coursenameesc =~ s/\ /\\\ /g;
	
	# Looking up contents of the course's directory
	$cmd = "ls -1A $courseroot/$coursenameesc";
	@allstudents = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};

	# Chopping off the line breaks from all array elements (otherwise the html source will look ugly):
	chomp(@allstudents);




	#$cmd = "pwd";
	#print "$cmd <br>\n";
	#$cmdreturn = `$cmd 2>&1`;
	#chomp($cmdreturn);
	#print "<i><font color='gray'><pre>";
	#print $cmdreturn ."<br>\n";   # The 2>&1 makes all screen output be written to the web page.
	#print "</pre></font></i>\n";


#	$cmd = "rm ./zipcontents/ -R";
	#print "$cmd <br>\n";
#	$cmdreturn = `$cmd 2>&1`;
	#print "<i><font color='gray'><pre>";
	#print $cmdreturn ."<br>\n";   # The 2>&1 makes all screen output be written to the web page.
	#print "</pre></font></i>\n";

#	$cmd = "mkdir ./zipcontents/";
	#print "$cmd <br>\n";
#	$cmdreturn = `$cmd 2>&1`;
	#print "<i><font color='gray'><pre>";
	#print $cmdreturn ."<br>\n";   # The 2>&1 makes all screen output be written to the web page.
	#print "</pre></font></i>\n";

	
#	$cmd = "cp $fpath/lastzip/* ./zipcontents -v";
	#print "$cmd <br>\n";
#	$cmdreturn = `$cmd 2>&1`;
#	chomp($cmdreturn);
	#print "<i><font color='gray'><pre>";
	#print $cmdreturn ."<br>\n";   # The 2>&1 makes all screen output be written to the web page.
	#print "</pre></font></i>\n";


}

# Displaying the files that were last submitted:
if ($continue eq "true")
{
	print "<h2>Files:</h2>";
	print "<table border=0 >\n";

	foreach my $onestudent (@allstudents) 
	{
		print "<td>";
		print "<b>${onestudent}</b>";
		print "</td>";
	}

	print "<tr>\n";
	foreach my $onestudent (@allstudents) 
	{
		# dateinamen erstellen und die datei auf dem server speichern
		$fpath = $courseroot . '/' . $coursename . '/' . $onestudent . '/lastzip';
		# Leerzeichen escapen...
		$fpath =~ s/\ /\\\ /g;	

		# Getting file list:
		$cmd = "ls -1A $fpath";
		@allfiles = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
		#if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};
		# Chopping off the line breaks from all array elements (otherwise the comparison below will not work):
		chomp(@allfiles);


		print "<td valign='top'>\n";
		print "<select size='30' disabled >";
		foreach my $file (@allfiles) 
		{
			# Display only .png files (match file name via regular expression):
			#if($file =~ /^sheet${sheetnumber}task${tasknumber}(.*)\.[pP][nN][gG]$/)
			#{
				print "<option>$file</option>\n";
			#}
		}
		print "</select>\n";
		print "</td>";

	}
	print "</tr>";
	print "</table>";

}

# Displaying the PNG images and .m-files:
if ($continue eq "true")
{


	my $tasknumber;
	for ($tasknumber = 1 ; $tasknumber <= 15 ; $tasknumber++)
	{
		print "<h2>Task $tasknumber:</h2>";
		print "<table border=1>\n";
		print "<tr>\n";
		foreach my $onestudent (@allstudents) 
		{
			print "<td colspan='2'>";
			print "<h3>Task $tasknumber of ${onestudent}:</h3>";
			print "</td>";
		}
		print "</tr>";
		print "<tr>";
		foreach my $onestudent (@allstudents) 
		{
			# dateinamen erstellen und die datei auf dem server speichern
			$fpath = $courseroot . '/' . $coursename . '/' . $onestudent . '/lastzip';
			# Leerzeichen escapen...
			$fpath =~ s/\ /\\\ /g;	# <-- ersetze alle Vorkommnisse von " " (leerzeichen) durch "\ " (backslash+leerzeichen).

			# Getting file list:
			$cmd = "ls -1A $fpath";
			@allfiles = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
			#if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};
			# Chopping off the line breaks from all array elements (otherwise the comparison below will not work):
			chomp(@allfiles);

			print "<td valign='top'>";
			foreach my $file (@allfiles) 
			{
				# Display only .png files (match file name via regular expression):
				if($file =~ /^sheet${sheetnumber}task${tasknumber}(.*)\.[pPjJgG][nNpPiI][gGfF]$/)   # If .PNG or .JPG or .GIF, then show image!
				{
					print "$1:<br>\n";
					print "<a href='/zipcontents/$onestudent/lastzip/$file'>";
					print "<image src='/zipcontents/$onestudent/lastzip/$file' width='200'>";
					print "</a><br><br>";
				}
			}
			print "</td><td valign='top'>";

			$cmd = "cat $fpath/sheet${sheetnumber}task${tasknumber}.m";
			#print "$cmd <br>\n";
			$cmdreturn = `$cmd 2>&1`;
			chomp($cmdreturn);
			print "<i><font color='gray'><pre>";
			print $cmdreturn ."<br>\n";   # The 2>&1 makes all screen output be written to the web page.
			print "</pre></font></i>\n";

			print "</td>";

		}
		print "</tr>\n";
		print "</table>\n";
	}

}


print "<br><br>";
#print "These are the flattened contents of ${studentname}'s last zip file. <br>\nPlease check to see if all files you zipped are here:";

#print "<i><font color='gray'><pre>";
#foreach my $file (@allfiles) 
#{
#	print $file ."\n";
#}
#print "</pre></font></i>\n";






print "Note: you can click on the images to view larger versions of them. If you use opera as a browser, the scaled images will appear in a much better quality.<br>\n";


if ($continue eq "false")
{
	print "<br><hr>&lt;-- Press the back button in your browser and try again.";
}

print "</body></html>";
