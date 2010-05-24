#!/usr/bin/perl -w 

use strict;
use CGI;
my $cgi = new CGI;
use CGI::Carp qw(fatalsToBrowser);

use DBI;
my $dbargs = {AutoCommit => 0,
              PrintError => 1};
my $dbh = DBI->connect("dbi:SQLite:dbname=../db/iteminfos.db","","",$dbargs);
    if ($dbh->err()) { die "$DBI::errstr\n"; }


my $itemroot = "/var/www/inventory/items";
my $tablerowbgcolor = "#ffffff";

my $cmd;
my $cmdoutput;

# Make HTML header:
print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>LabTracker: ISIP Inventory Webapplication</title></head><body link='#000000' vlink='#000000' alink='blue' bgcolor='#E0E0E0'>\n";
print "<font FACE='Helvetica, Arial, Verdana, Tahoma'>";
print "<h1>LabTracker ISIP Inventory Webapplication</h1>\n";
print "(<a href='http://en.wikipedia.org/wiki/WebDAV#Implementations'>Mount</a> <i><b>https://inventory.isip.uni-luebeck.de/items/</b></i> as a network drive for uploading images via the file system.)<br>\n";
#print "<br>\n";

#################
### Housekeeping:
#################

# Rebuild thumbnail images?
my  $thumbnailresolution 		= $cgi->param('thumbnailresolution');
if (!(defined $thumbnailresolution)){$thumbnailresolution = "48"} # may lead to differently sized icons for new items if old ones are non-48. But who cares?
else 
{
	print "<font color='gray'>(Rebuilding thumbnails at height $thumbnailresolution px!)</font><br>\n";
	# execute the delete command
	$cmd = "rm $itemroot/../thumbs/ -R";
	my @mkdirerror = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	if ($?) {print "<pre>@mkdirerror</pre> <br>\n";print '<font color="red">Careful here: Creating the thumbnail folder for $imagefilename has not worked! Read the gray screen output to find out why.</font>';};
}


#create the item folder if it does not exist yet (new server?):
if (!(-e "$itemroot/."))
{
	$cmd = "mkdir -p \"$itemroot/\"";
	my @mkdirerror2 = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	if ($?) 
	{
		print "<pre>@mkdirerror2</pre> <br>\n";
		print '<font color="red">Careful here: Creating the item folder for the first time has not worked! Read the gray screen output to find out why.</font>';
	}
	else {print "The item folder has been created. This is the first execution on a new server, isn't it?";}
}


##########################################
### Insert new item folders into Database:
##########################################

$cmd = "ls -1A $itemroot/";
my @allitemfolders = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
if ($?) {print '<font color="red">Careful here: Listing all item folders has not worked! Read the gray screen output to find out why.</font>';};

# Chopping off the line breaks from all array elements (otherwise the comparison below will not work):
chomp(@allitemfolders);

my %categories;
my $categoryname;
my %items;


my $sth = $dbh->prepare("SELECT * FROM items WHERE item_folder = ? ;");
if ($sth->err()) { die "$DBI::errstr\n"; }

foreach my $itemfolder (@allitemfolders) 
{
  if ( ( $itemfolder !~ m/^\./ ) and ( $itemfolder !~ m/^readme.txt$/ ) )
  {
	$sth->execute($itemfolder);

	my $existsInDB = 0;
	while(my @row = $sth->fetchrow_array())
	{
	$existsInDB = 1;
	#print "The folder $itemfolder is already in the database.\n";
	#print "$row[0], $row[2], $row[3]\n";
	}

	# check if folder is already in DB
	if (!$existsInDB)
	{
	    # check if this is really a directory and if it contains valid characters: m/^\w(\w|\.)+$/
	    if (-d "$itemroot/$itemfolder")
		{
		    if ( $itemfolder =~ m/^\w(\w|\.|\-)+$/ )
		    {
				my $rv = $dbh->do("INSERT INTO items (item_folder,item_name,item_description,item_room,item_category,item_state) VALUES ('$itemfolder','$itemfolder','...','0','0','Functional')");
				print "<font color='gray'>(The new item '$itemfolder' was inserted into the database.)</font><br>\n";
				#print "rv=$rv<br>\n";
		
				#my @row_ary = $dbh->selectrow_array("SELECT * FROM items ");
				#print "$row_ary[0], $row_ary[2], $row_ary[3]\n";	
		
				$dbh->commit();
				### insert!
		    }
		    else
	        {
				print "<font color='gray'>(No database item was created for '$itemfolder' because it contains invalid characters! Please rename the folder.)</font><br>\n";
			}
		}
		else
		{
				print "<font color='gray'>(No database item was created for '$itemfolder' because it is not even a folder! Please remove the file and create a folder instead.)</font><br>\n";
		}
	}
	else
	{
    	    #print "nothing to be done.<br>\n";
	}
  }
}


###################################
### Output list of inventory items:
###################################
#print "<h2>These items exist in the inventory database:</h2>\n";

# Jetzt geht es an die eigentliche Ausgabe als HTML-Text!
# Wir wollen dazu für jede Kategorie eine HTML-Tabelle mit den Inventargegenständen ausgeben.
# Dabei soll immer ein Gegenstand pro Tabellenzeile ausgegeben werden.

my $categoryrowsref = $dbh->selectall_arrayref("SELECT category_id, category_name FROM categories ORDER BY category_id;");
foreach my $categoryrowref (@{$categoryrowsref})
{
	my @categoryrow = @{$categoryrowref};

	my $category_id = @categoryrow[0];
	my $category_name = @categoryrow[1];

	# Get all items for current category (the ending "ref" stands for "reference", so think pointers!):
	my $allitemrowsref = $dbh->selectall_arrayref("SELECT item_folder,item_linkedfolder,item_name,item_description,item_state,item_wikiurl,item_room,item_shelf,item_currentuser,item_invoicedate,item_uniinvnum,item_category , rooms.room_id, rooms.room_number, rooms.room_floor, rooms.room_building, rooms.room_name, item_versionnumber, item_serialnumber FROM items LEFT JOIN rooms ON items.item_room=rooms.room_id WHERE item_category='$category_id';");
	
	my $itemcount = scalar(@{$allitemrowsref});
	if ($itemcount > 0)
	{  # closing bracket far below..
		print "<h3>$category_name:</h3>";
		#print "items in category $category_id: $len -> @{$allitemrowsref}";

		# Dann kommt eine HTML-Tabelle, die die ganzen Inventargegenstände dieser Kategorie
		# enthält. Erst kommen die Überschriften, ...
		print "<TABLE BORDER=1 rules='cols' CELLSPACING=0 CELLPADDING=0 width='100%' BORDERCOLOR='#6b7f93'>";
		print "<TR ALIGN='middle' VALIGN='middle' bgcolor='#6b7f93' text='#ffffff' > ";
		print "<th><font color='white'> Item Name & Model </font></th>";
		print "<th><font color='white'> Photos </font></th>";
		print "<th><font color='white'> Location & User </font></th>";
		print "<th><font color='white'> Serial </font></th>";
		print "<th><font color='white'>State</font></th>";
		print "<th><font color='white'> Wiki-link </font></th>";
		print "</tr>";
		# ... dann kommen die eigentlichen Inventurgegenstände.
		# Mit @{$categoryitems} sagen wir Perl, dass die Variable $categoryitems in Wirklichkeit 
		# ein Array ist (markiert durch das @-Zeichen), damit wir darüber iterieren können.
	#	foreach my $oneItem (@{$categoryitems})
		foreach my $itemrowref (@{$allitemrowsref})
		{
			my @itemrow = @{$itemrowref};

			my $item_folder = @itemrow[0];
			my $item_basedon = @itemrow[1];
			my $item_name = @itemrow[2];
			my $item_description = @itemrow[3];
			my $item_state = @itemrow[4];
			my $item_wikiurl = @itemrow[5];
			my $item_room = @itemrow[6];
			my $item_shelf = @itemrow[7];
			my $item_currentuser = @itemrow[8];
			my $item_invoicedate = @itemrow[9];
			my $item_uniinvnum = @itemrow[10];
			my $item_category = @itemrow[11];
			my $item_versionnumber = @itemrow[17];
			my $item_serialnumber = @itemrow[18];

			my $room_id = @itemrow[12];
			my $room_number = @itemrow[13];
			my $room_floor = @itemrow[14];
			my $room_building = @itemrow[15];
			my $room_name = @itemrow[16];


			# Die HTML-Zeile soll anklickbar sein, also müssen wir den HTML-Link vorbereiten:
			my $itemfolderlink = "itemmenu.pl?itemfolder=$item_folder";
			
			# Hier wird dann die eigentliche Zeile der HTML-Tabelle ausgegeben:
			print "<TR ALIGN='middle' VALIGN='middle' bgcolor='$tablerowbgcolor'>\n";

			print "<a></a><td ALIGN='left'>&nbsp;<a name='$item_folder' href='$itemfolderlink'>$item_name</a> $item_versionnumber</td>\n";
			print "<td>\n";
			
		  if (-e "$itemroot/$item_folder")
		  {

			$cmd = "ls -1A $itemroot/$item_folder";
			my @allitemsfiles = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
			if ($?) {print '<font color="red">Careful here: Listing contents of item folder has not worked! Read the gray screen output to find out why.</font>';};
			# Chopping off the line breaks from all array elements (otherwise the comparison below will not work):
			chomp(@allitemsfiles);

			foreach my $imagefilename (@allitemsfiles)
			{
				# for each file that starts with a letter and ends with .jpg, .png or .gif
				if ( ((substr($imagefilename, -4) eq (".jpg")) or (substr($imagefilename, -4) eq (".png")) or (substr($imagefilename, -4) eq (".gif")))
					and ($imagefilename =~ m/^\w(\w|\.)+$/) )
				{
					my $thumbnailfile = "$itemroot/../thumbs/$item_folder/$imagefilename";

					#create thumbnail folder if it does not exist yet:
					if (!(-e "$itemroot/../thumbs/$item_folder/."))
					{
						$cmd = "mkdir -p \"$itemroot/../thumbs/$item_folder\"";
						my @mkdirerror = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
						if ($?) {print "<pre>@mkdirerror</pre> <br>\n";print '<font color="red">Careful here: Creating the thumbnail folder for $imagefilename has not worked! Read the gray screen output to find out why.</font>';};
					}

					# generate thumbnail if it does not exist yet
					if (!(-e $thumbnailfile))
					{
						#`"mkdir \"$itemroot/../thumbs/$item_folder\""`;
						$cmd = "convert \"$itemroot/$item_folder/$imagefilename\" -resize x$thumbnailresolution \"$thumbnailfile\"";
						my @outputlines = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
						
						if ($?) {print "<pre>@outputlines</pre> <br>\n";print '<font color="red">Careful here: Converting the image has not worked! Read the gray screen output to find out why.</font>';};
					}
					else
					{
						#print "thumbnail of $imagefilename already there.<br>\n"
					}
					
					# link to thumb				
					print "<a href='$itemfolderlink#$imagefilename'><img border=0 src='thumbs/$item_folder/$imagefilename'></a> ";
				}
			}
		  }
		  else
		  {
			print "<a href='repairfolder.pl?item_folder=$item_folder'><font color='red'>Alert: The photo folder of this item was not found! Was is renamed or deleted via WebDAV? Click to repair!</font></a>";
		  }

			#print "@allitemsfiles";
			print "</td>\n";
			print "<td>$room_name $item_shelf $item_currentuser</td>\n";
			print "<td>$item_serialnumber</td>\n";
			print "<td>";
			if ($item_state eq "Functional")
				{print "<img src='/style/lights_green.png' alt='$item_state'>";}
			elsif ($item_state eq "Destroyed")
				{print "<img src='/style/lights_red.png' alt='$item_state'>";}
			else
				{print "<img src='/style/lights_yellow.png' alt='$item_state'>";}
			print "</td>\n";
			
			# wiki URL:
			if (length($item_wikiurl) > 0 )
			{
				print "<td ALIGN='middle'><a href='$item_wikiurl'> visit</a></td>\n";
			}
			else
			{
				print "<td ALIGN='middle'></td>\n";
			}
			print "</tr>\n";

			# for alternating table row colours:
			if ($tablerowbgcolor eq "#d1e8f9")
			{
				$tablerowbgcolor = "#ffffff";
			}
			else
			{
				$tablerowbgcolor = "#d1e8f9"
			}
		}
		print "</table>";
	} # closing the if items>0 clause
} # closing category enumeration

# Die Datenbank wird ab jetzt nicht mehr gebraucht. Also wird sie geschlossen:
$dbh->disconnect();



########################
### New Item Button
########################
print "<br>";
print "<input type='button' value='Create New Item' onclick='document.location.href=\"createitem.pl\"'>";
print " ... or you can make a new folder in the shared file system if you have mounted the network drive! See above.";
print "<br>";



print "<br>";
print "<a href='/?thumbnailresolution=30' method=\"post\"> Rebuild thumbnails at 30 pixels </a> <br>\n";
print "<a href='/?thumbnailresolution=48'> Rebuild thumbnails at 48 pixels </a> <br>\n";
print "<a href='/?thumbnailresolution=100'> Rebuild thumbnails at 100 pixels </a> <br>\n";
print "<br>";
print "<br>";

print "</body></html>\n";

