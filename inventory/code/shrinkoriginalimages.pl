#!/usr/bin/perl -w

use strict;
#use CGI;
#my $cgi = new CGI;
#use CGI::Carp qw(fatalsToBrowser);

#use DBI;    
#my $dbargs = {AutoCommit => 0,
#              PrintError => 1};
#my $dbh = DBI->connect("dbi:SQLite:dbname=../db/iteminfos.db","","",$dbargs);
#    if ($dbh->err()) { die "$DBI::errstr\n"; }
        


my $itemroot = "/var/www/inventory/items";

#my $cgi_item_folder = $cgi->param('itemfolder');
#my $cgi_item_uniqueID = $cgi->param('itemID');

my $cmd;
my $cmdoutput;

print "Content-type: text/html\n\n";        
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";                                                                                                      
print "<html><head><title>LabTracker - Shirinking images</title></head>";                                                                                                             
print "<body bgcolor='#E0E0E0'>\n";                                                                                                                                                 
print "<font FACE='Helvetica, Arial, Verdana, Tahoma'>";                                                                                                                            

#print "<pre>";
# see sub-procedure at end of file.
showPhotos();
#print "</pre>";

print "<a href='mainmenu.pl'>Now load main menu!</a>";
print "</body></html>\n";                                                                                                                                                           
 

sub showPhotos
{

    ## Anzeigen der Miniatur-Photos:
    #
    # Die HTML-Zeile soll anklickbar sein, also müssen wir den HTML-Link vorbereiten:

#    print "<u>Photos (click them!):</u><br>";

    my $thumbnailresolution = 2560;
    
    print "<h3>Shrinking original images to at most $thumbnailresolution pixels width...</h3>\n";                                                                                                                                                

    
    my @otheritemfilenames;

    my @allitemfolders = `ls -1 $itemroot`;
    
    chomp(@allitemfolders);
  foreach my $item_folder (@allitemfolders)
  {
    #print "\n$itemroot/$item_folder:\n";
    if (-d "$itemroot/$item_folder")
    {

        $cmd = "ls -1 $itemroot/$item_folder";
        my @allitemsfiles = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
        if ($?) {print '<font color="red">Careful here: Listing contents of item folder has not worked! Read the gray screen output to find out why.</font>';};
        # Chopping off the line breaks from all array elements (otherwise the comparison below will not work):
        chomp(@allitemsfiles);
	
	my $numberofImages=0;
	foreach my $imagefilename (@allitemsfiles)
	{
		# for each file that starts with a letter and ends with .jpg, .png or .gif, ignoring the case.
		if ($imagefilename =~ m/^\w.*\.(jpg|jpeg|gif|png)$/i)
		{
				$cmd = "identify \"$itemroot/$item_folder/$imagefilename\"";
				#$cmd = "ls \"$itemroot/$item_folder/$imagefilename\"";
				#$cmd = "convert -verbose \"$itemroot/$item_folder/$imagefilename\" -resize '$thumbnailresolution>' \"$itemroot/$item_folder/$imagefilename\"";
				my @outputlines = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.				
				#chomp (@outputlines);
	#			my $line = @outputline[0];
				my $matches = @outputlines[0] =~ m/$itemroot(\/[^\s]+)\s.*\s((\d+)x\d+)\s/;
				my $imgpath = $1;
				my $imgsize = $2;
				my $imgwidth = $3;
				if ($imgwidth <= $thumbnailresolution)
				{
    				    print "$imgsize (not shrinking): $imgpath <br>";
				}
				else
				{
    				    print "<font color=blue>$imgsize (shrinking): &nbsp;&nbsp; $imgpath </font><br>";				    
				    $cmd = "convert -verbose \"$itemroot/$item_folder/$imagefilename\" -resize '$thumbnailresolution>' \"$itemroot/$item_folder/$imagefilename\"";
				    @outputlines = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.				
				    print "<pre>";
				    foreach my $line (@outputlines)
				    {
					$line =~ s/$itemroot//;
					print "$line";
				    }
				    print "</pre>";
				}
				
				if ($?) {print '<font color="red">Careful here: Converting the image has not worked! Read the screen output to find out why.</font><br>\n';};
		}
	}
    }
    else
    {
	print "/$item_folder is not a directory.<br>\n";
    }
    ## Ende der photos
  }


#    ## Andere Dateien:
#    print "<br><br><u>Other files:</u><br>";

#    if (@otheritemfilenames)
#    {
#    #	print "<h3>Other files:</h3>";
#	foreach my $otherfilename (@otheritemfilenames)
#	{
#		#chomp ($otherfilename);
#		print "<a href='items/$item_folder/$otherfilename'><font color='grey'>$otherfilename</font></a><br>\n";
#	}
#    }
#    else
#    {
#	print "<font color='grey'>none.</font><br>\n";
#    }
#    
#    print "<br>\n";

}