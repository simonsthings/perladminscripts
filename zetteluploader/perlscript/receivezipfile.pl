#!/usr/bin/perl -w

use strict;
use CGI; # Modul fuer CGI-Programme

my $cgi = new CGI; # neues Objekt erstellen

my $courseroot = "/var/www/zettelupload/data";
my $maxfilenamelength = 40;
my @extensions = qw(zip);

# die datei-daten holen
my $file = $cgi->param("myfile");
# Get the Name of the Course:
my $coursename = $cgi->param('coursename');
# Get the Name of the Student:
my $studentname = $cgi->param('studentname');
# Get the PIN of the Student:
my $studentpin = $cgi->param('mypin');


# Send HTML header to browser:
print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>ISIP Task Submission</title></head><body bgcolor='#E0E0E0'>\n";
print "<h1>Hello $studentname,</h1>\n";


# Check if the PIN is correct...
my $pincorrect = "false";
open FILE,'<'.$coursename.'.htpasswd' or die 'Error dealing with input file: ',$!;
while (my $line = <FILE>)
{	
	# cut away line break:
	chomp($line);
	
	# Regular Expression to get the parts *before* and *after* the colon in the line:
	$line =~ /([^:]*):([^:]*)/;

	# Activate this to open security hole (or do debugging). Generate new passwords afterwards!
	#print "Test Mode: student <b>$1</b> has pin <b>$2</b>, given student <b>$studentname</b> has given pin <b>$studentpin</b> <br>\n";
	
	# Check if the given student has entered the correct PIN.
	if (($studentname eq $1) && ($studentpin eq $2))
	{
		$pincorrect = "true";
	}
}
close FILE;

my $continue = "true";
if ($pincorrect ne "true")
{
	print "Sorry, but the PIN code you entered is incorrect!<br>\n";
	$continue = "false";
}
else
{
	print "Your PIN is correct.\n";
	print "<h3>Examining the file name</h3>\n";
}

# Check if upload field was empty:
if (length($file) == 0)
{
	print "Please enter a file name.<br>\n" ;
	$continue = "false";
}

# Check for length of file name:
if (length($file) > $maxfilenamelength)
{
	print "Sorry, but your filename is too long! Please use a file name shorter than $maxfilenamelength characters.<br>" ;
	$continue = "false";
}

# Check for illegal characters in file:
my $filenameprefix;
my $filenamepostfix;
if ($continue eq "true")
{
	if($file !~ /^([a-z\.\-A-Z0-9]+?)\.([a-zA-Z0-9]{3})$/)
	{
		print("Sorry, but your file \"$file\" contains characters other than a-z, A-Z, 0-9, or - . <br>\nPlease change your file name before uploading.");
		$continue = "false";
	}
	$filenameprefix = $1;
	$filenamepostfix = $2;
}

# Check for file extension:
if ($continue eq "true")
{

	# Check if the extension is allowed. (The perl grep function doesn't work and probably needs some additioinal include.)
	my $extensionisinlist = "no";
	foreach my $ext (@extensions)
	{
		if ($ext eq $filenamepostfix)
		{
			$extensionisinlist = "yes";
		}	
	}
	if ($extensionisinlist eq "no")
	{
		print("Sorry, but your filename extension is not allowed. The only allowed file name extensions are: <b>@extensions</b>");
		$continue = "false";
	}
}

# Do file upload:
my $cmd;
my $cmdreturn;
my $fpath;
my $fname;
if ($continue eq "true")
{
	print "ok!<br>\n<br>\n";

	#print "<hr>\n";
	print "<h3>Uploading file</h3>\n";

	# dateinamen erstellen und die datei auf dem server speichern
	$fpath = $courseroot . '/' . $coursename . '/' . $studentname ;
	$fname = $filenameprefix .'_ip'.$ENV{REMOTE_ADDR}.'ts'.time . '.' .$filenamepostfix;
	open DAT,'>'.$fpath.'/'.$fname or die 'Error processing file: ',$!;

	# Dateien in den Binaer-Modus schalten
	binmode $file;
	binmode DAT;

	my $data;
	while(read $file,$data,1024) {
	  print DAT $data;
	}
	close DAT;

	print "Your file <b>$file</b> has been uploaded and stored as <b>$fname</b>.<br>\n";
	print "<br>\n";

	# Leerzeichen escapen...
	$fpath =~ s/\ /\\\ /g;

	#print "Listing your current directory contents:<br>\n";
	#$cmd = "ls -1A $fpath";
	#$cmdreturn = `$cmd 2>&1`;
	#print "<i><font color='gray'><pre>";
	#print $cmdreturn ."<br>\n";   # The 2>&1 makes all screen output be written to the web page.
	#print "</pre></font></i>\n";

	# If a zip file was uploaded, we can continue to unzip it:
	if ($filenamepostfix ne "zip")
	{
		print "The uploaded file is not a zip file so it will obviously not be unpacked.<br>\n";
		$continue = "false";
	}
}


if ($continue eq "true")
{
	print "<h3>Unpacking zip file</h3>\n";

	$cmd = "rm $fpath/lastzip/ -R";
	#print "$cmd <br>\n";
	$cmdreturn = `$cmd 2>&1`;
	#print "<i><font color='gray'><pre>";
	#print $cmdreturn ."<br>\n";   # The 2>&1 makes all screen output be written to the web page.
	#print "</pre></font></i>\n";

	$cmd = "mkdir $fpath/lastzip/";
	#print "$cmd <br>\n";
	$cmdreturn = `$cmd 2>&1`;
	#print "<i><font color='gray'><pre>";
	#print $cmdreturn ."<br>\n";   # The 2>&1 makes all screen output be written to the web page.
	#print "</pre></font></i>\n";

	$cmd = "unzip -j $fpath/$fname -d $fpath/lastzip ";
	#print "$cmd <br>\n";
	$cmdreturn = `$cmd 2>&1`;
	#print "<i><font color='gray'><pre>";
	#print $cmdreturn ."<br>\n";   # The 2>&1 makes all screen output be written to the web page.
	#print "</pre></font></i>\n";

	print "These are the flattened contents of your zip file. Please check to see if all files you zipped are here:";

	$cmd = "ls -1A $fpath/lastzip";
	#print "$cmd <br>\n";
	$cmdreturn = `$cmd 2>&1`;
	chomp($cmdreturn);
	print "<i><font color='gray'><pre>";
	print $cmdreturn ."<br>\n";   # The 2>&1 makes all screen output be written to the web page.
	print "</pre></font></i>\n";

	print "<h3>Executing in Matlab</h3>\n";
	print "...not implemented yet!<br><br>\n";

	print "<hr>";

}


if ($continue eq "false")
{
	print "<br><hr>&lt;-- Press the back button in your browser and try again.";
}

print "</body></html>";

