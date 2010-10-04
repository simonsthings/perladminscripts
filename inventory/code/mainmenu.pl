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
my $docroot = "$ENV{DOCUMENT_ROOT}";                                                                                                                         
my $mainmenucache = "mainmenu.html";
my $tablerowbgcolor = "#ffffff";

                                                                                                                                                             
#my $cgi_item_folder = $cgi->param('itemfolder');                                                                                                             
my $cgi_item_uniqueID = $cgi->param('itemID');                                                                                                               
 
my $cmd;
my $cmdoutput;

open(OUTKFILE, "> $docroot/$mainmenucache") or die "Can't write to file $mainmenucache: $!";

# Make HTML header:
print OUTKFILE '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print OUTKFILE "<html><head><title>LabTracker - Main Menu</title>";
#print OUTKFILE "<meta HTTP-EQUIV=\"REFRESH\" content=\"2; url=/$mainmenucache#$ENV{QUERY_STRING}\">";                                                                              
print OUTKFILE "</head><body link='#000000' vlink='#000000' alink='blue' bgcolor='#E0E0E0'>\n";
print OUTKFILE "<font FACE='Helvetica, Arial, Verdana, Tahoma'>";
#print OUTKFILE "<h1>LabTracker ISIP Inventory Webapplication</h1>\n";
#print OUTKFILE "(<a href='http://en.wikipedia.org/wiki/WebDAV#Implementations'>Mount</a> <i><b>https://inventory.isip.uni-luebeck.de/items/</b></i> as a network drive for uploading images via the file system.)<br>\n";
#print OUTKFILE "<br>\n";

print OUTKFILE "<input type='button' value='Refresh this list' onclick='document.location.href=\"mainmenu.pl\"'>";
print OUTKFILE "<input type='button' value='Create New Item' onclick='document.location.href=\"createitem.pl\"'>";
print OUTKFILE "<input type='button' value='Show complete History' onclick='document.location.href=\"historylist.pl\"'>";
print OUTKFILE "<br>";

#print OUTKFILE "hallaaa";
#print OUTKFILE "docroot = $docroot ! <br><br>";                                                                                                                       
   





#################
### Housekeeping:
#################

# Rebuild thumbnail images?
my  $thumbnailresolution 		= $cgi->param('thumbnailresolution');
if (!(defined $thumbnailresolution)){$thumbnailresolution = "48"} # may lead to differently sized icons for new items if old ones are non-48. But who cares?
else 
{
	print OUTKFILE "<font color='gray'>(Rebuilding thumbnails at height $thumbnailresolution px!)</font><br>\n";
	# execute the delete command
	$cmd = "rm $itemroot/../thumbs/ -R";
	my @mkdirerror = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	if ($?) {print OUTKFILE "<pre>@mkdirerror</pre> <br>\n";print OUTKFILE '<font color="red">Careful here: Creating the thumbnail folder for $imagefilename has not worked! Read the gray screen output to find out why.</font>';};
}


#create the item folder if it does not exist yet (new server?):
if (!(-e "$itemroot/."))
{
	$cmd = "mkdir -p \"$itemroot/\"";
	my @mkdirerror2 = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
	if ($?) 
	{
		print OUTKFILE "<pre>@mkdirerror2</pre> <br>\n";
		print OUTKFILE '<font color="red">Careful here: Creating the item folder for the first time has not worked! Read the gray screen output to find out why.</font>';
	}
	else {print OUTKFILE "The item folder has been created. This is the first execution on a new server, isn't it?";}
}


##########################################
### Insert new item folders into Database:
##########################################

$cmd = "ls -1A $itemroot/";
my @allitemfolders = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
if ($?) {print OUTKFILE '<font color="red">Careful here: Listing all item folders has not worked! Read the gray screen output to find out why.</font>';};

# Chopping off the line breaks from all array elements (otherwise the comparison below will not work):
chomp(@allitemfolders);

my %categories;
my $categoryname;
my %items;


my $sth = $dbh->prepare("SELECT * FROM items WHERE item_folder = ? ;");
my $sthforinsert = $dbh->prepare("SELECT item_uniqueID FROM items WHERE item_folder = ? ;");
if ($sth->err()) { die "$DBI::errstr\n"; }
if ($sthforinsert->err()) { die "$DBI::errstr\n"; }

foreach my $itemfolder (@allitemfolders) 
{
  if ( ( $itemfolder !~ m/^\./ ) and ( $itemfolder !~ m/^readme.txt$/ ) )
  {
	$sth->execute($itemfolder);

	my $existsInDB = 0;
	while(my @row = $sth->fetchrow_array())
	{
	    $existsInDB = 1;
	    #print OUTKFILE "The folder $itemfolder is already in the database.\n";
	    #print OUTKFILE "$row[0], $row[2], $row[3]\n";
	}
	
	$sth->finish;


	# check if folder is already in DB
	if (!$existsInDB)
	{
	    # check if this is really a directory and if it contains valid characters: m/^\w(\w|\.)+$/
	    if (-d "$itemroot/$itemfolder")
		{
		    if ( $itemfolder =~ m/^\w(\w|\.|\-)+$/ )
		    {
				my $rv = $dbh->do("INSERT INTO items (item_folder,item_name,item_description,item_room,item_category,item_state) VALUES ('$itemfolder','$itemfolder','...','0','0','Functional')");
				#print OUTKFILE "rv=$rv<br>\n";
		
				#my @row_ary = $dbh->selectrow_array("SELECT * FROM items ");
				#print OUTKFILE "$row_ary[0], $row_ary[2], $row_ary[3]\n";	
		
				$dbh->commit();
				### insert!				
				
				# track operation in history table:
				$sthforinsert->execute($itemfolder);
				my $uniqueID=0; # valid values begin at 1!
				while ( (my $id) = $sthforinsert->fetchrow_array() )
				{
				    # Make sure than only one item with the given folder name exists:
				    die("Error in implementation: There are more than one item in the DB with the folder name '$itemfolder'! This code should never have been reached!") unless($uniqueID==0);
				    
				    # Assign newly created unique ID to variable:
				    $uniqueID = $id;
				    #print OUTKFILE "These UIDs exist for the given folder: $uniqueID<br>\n";
				}
				$sthforinsert->finish();
				my $time = time();
				
				saveHistory($uniqueID,'CREATE_AUTOWEBDAV');
				
				#print OUTKFILE "Inserting ID=$uniqueID, ITEM=$itemfolder, TIME=$time !";
				#my $h =  $dbh->do("INSERT INTO history (history_itemuniqueid,history_operation,history_operationtime,history_xmlblob) VALUES ($uniqueID,'CREATE_AUTOWEBDAV',$time,'<td title=\"Item Name\">$itemfolder</td><td title=\"Item Unix Folder\">$itemfolder</td><td title=\"Item Description\">...</td>')");				
				$dbh->commit();
				
				print OUTKFILE "<font color='gray'>(The new item '<a href='itemmenu.pl?itemID=$uniqueID'><font color='gray'>$itemfolder</font></a>' was created in the database because someone created a folder by that name using the shared network drive.)</font><br>\n";
		    }
		    else
	        {
				print OUTKFILE "<font color='gray'>(No database item was created for '$itemfolder' because it contains invalid characters! Please rename the folder.)</font><br>\n";
			}
		}
		else
		{
				print OUTKFILE "<font color='gray'>(No database item was created for '$itemfolder' because it is not even a folder! Please remove the file and create a folder instead.)</font><br>\n";
		}
	}
	else
	{
    	    #print OUTKFILE "nothing to be done.<br>\n";
	}
	
  }
}
# finish this operation
$sth->finish();


###################################
### Output list of inventory items:
###################################
#print OUTKFILE "<h2>These items exist in the inventory database:</h2>\n";

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
	my $allitemrowsref = $dbh->selectall_arrayref("SELECT item_folder,item_linkedfolder,item_name,item_description,item_state,item_wikiurl,item_room,item_shelf,item_currentuser,item_invoicedate,item_uniinvnum,item_category , rooms.room_id, rooms.room_number, rooms.room_floor, rooms.room_building, rooms.room_name, item_versionnumber, item_serialnumber, item_workgroup, item_responsibleperson, item_uniqueID FROM items LEFT JOIN rooms ON items.item_room=rooms.room_id WHERE item_category='$category_id' ORDER BY item_name,item_versionnumber,item_serialnumber  ;");
	
	my $itemcount = scalar(@{$allitemrowsref});
	if ($itemcount > 0)
	{  # closing bracket far below..
		print OUTKFILE "<h3>$category_name:</h3>";
		#print OUTKFILE "items in category $category_id: $len -> @{$allitemrowsref}";

		# Dann kommt eine HTML-Tabelle, die die ganzen Inventargegenstände dieser Kategorie
		# enthält. Erst kommen die Überschriften, ...
		print OUTKFILE "<TABLE BORDER=1 rules='cols' CELLSPACING=0 CELLPADDING=0 width='100%' BORDERCOLOR='#6b7f93'>";
		print OUTKFILE "<TR ALIGN='middle' VALIGN='middle' bgcolor='#6b7f93' text='#ffffff' > ";
		print OUTKFILE "<th><font color='white'> Name, Model, Serial </font></th>";
		print OUTKFILE "<th><font color='white'> Photos </font></th>";
		print OUTKFILE "<th><font color='white'> Location & User </font></th>";
		print OUTKFILE "<th><font color='white'> Wiki-link </font></th>";
		print OUTKFILE "<th><font color='white'>State</font></th>";
		print OUTKFILE "</tr>";
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

			my $room_id = @itemrow[12];
			my $room_number = @itemrow[13];
			my $room_floor = @itemrow[14];
			my $room_building = @itemrow[15];
			my $room_name = @itemrow[16];

			my $item_versionnumber = @itemrow[17];
			my $item_serialnumber = @itemrow[18];
			my $item_workgroup = @itemrow[19];
			my $item_responsibleperson = @itemrow[20];
			my $item_uniqueID = @itemrow[21];

			# Die HTML-Zeile soll anklickbar sein, also müssen wir den HTML-Link vorbereiten:
			my $itemfolderlink = "itemmenu.pl?itemID=$item_uniqueID";
			
			# Hier wird dann die eigentliche Zeile der HTML-Tabelle ausgegeben:
			print OUTKFILE "<TR title='item$item_uniqueID: WebDAV Folder https://inventory.isip.uni-luebeck.de/items/$item_folder/' ALIGN='middle' VALIGN='middle' bgcolor='$tablerowbgcolor'>\n";

			print OUTKFILE "<td width='33%' ALIGN='left'><table border=0><td><a name='item$item_uniqueID' href='$itemfolderlink'>$item_name</a> $item_versionnumber";
			if ($item_serialnumber ne "")
			{
			    print OUTKFILE ", $item_serialnumber\n";
			}
			print OUTKFILE "</td></table></td>\n";
			
			# Photos:
			print OUTKFILE "<td width='33%'>\n";
			
			listPhotos($item_uniqueID,$item_folder,$itemfolderlink);
			
			#print OUTKFILE "@allitemsfiles";
			print OUTKFILE "</td>\n";

			# Location & User:
			my $colon = "";
			my $semicolon = "";
			my $usedbystring = "";
			if ($room_name ne "" && $item_shelf ne "") {$colon = ": "}
			if ($room_name ne "" || $item_shelf ne "") {$semicolon = ", "}
			if ($item_currentuser ne "") {$usedbystring = "${semicolon}used by "};
			print OUTKFILE "<td width='33%'>$room_name$colon$item_shelf$usedbystring$item_currentuser</td>\n";
			
			# wiki URL:
			if (length($item_wikiurl) > 0 )
			{
				print OUTKFILE "<td ALIGN='middle'><a href='$item_wikiurl'> visit</a></td>\n";
			}
			else
			{
				print OUTKFILE "<td ALIGN='middle'></td>\n";
			}
			
			# State:			
			print OUTKFILE "<td>";
			if ($item_state eq "Functional")
				{print OUTKFILE "<img src='/style/lights_green.png' alt='$item_state'>";}
			elsif ($item_state eq "Destroyed")
				{print OUTKFILE "<img src='/style/lights_red.png' alt='$item_state'>";}
			else
				{print OUTKFILE "<img src='/style/lights_yellow.png' alt='$item_state'>";}
			print OUTKFILE "</td>\n";
			
			print OUTKFILE "</tr>\n";

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
		print OUTKFILE "</table>";
	} # closing the if items>0 clause
} # closing category enumeration

# Die Datenbank wird ab jetzt nicht mehr gebraucht. Also wird sie geschlossen:
$dbh->disconnect();



########################
### New Item Button
########################
print OUTKFILE "<br>";
print OUTKFILE "<input type='button' value='Create New Item' onclick='document.location.href=\"createitem.pl\"'>";
print OUTKFILE " Or create folder in WebDAV!";
#print OUTKFILE " ... or you can make a new folder in the shared file system if you have mounted the network drive! See above.";
print OUTKFILE "<br>";

print OUTKFILE "<br>";
print OUTKFILE "<a href='historylist.pl'> Show complete history of all changes! </a> <br>\n";


print OUTKFILE "<br>";
print OUTKFILE "<a href='/mainmenu.pl?thumbnailresolution=30' > Rebuild thumbnails at 30 pixels </a> <br>\n";
print OUTKFILE "<a href='/mainmenu.pl?thumbnailresolution=48' > Rebuild thumbnails at 48 pixels </a> <br>\n";
print OUTKFILE "<a href='/mainmenu.pl?thumbnailresolution=100'> Rebuild thumbnails at 100 pixels </a> <br>\n";
print OUTKFILE "<br>";
print OUTKFILE "<a href='/shrinkoriginalimages.pl'> Shrink all original images to maximum 2560 pixels width. </a> <br>(To increase speed of the LabTracker after first import of new items.) <br>\n";
print OUTKFILE "<br>";
print OUTKFILE "<br>";

my $timestring = scalar( localtime(time));
print OUTKFILE "This page was generated at $timestring .<br>\n";

print OUTKFILE "</body></html>\n";

close(OUTKFILE);

# This page needs to also send something to the server. Make a page that redirects!
print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>LabTracker - Main Menu</title>";
print "<meta HTTP-EQUIV=\"REFRESH\" content=\"0; url=/$mainmenucache#item$cgi_item_uniqueID\">";                                                                              
print "</head>";
#print "<body>";
#print "<h1>here now:</h1>";
#print OUTKFILE "out: $ENV{QUERY_STRING}";
#foreach my $key (keys %ENV) {#                                                                                                                             
#       print "$key --> $ENV{$key}<br>";                                                                                                             
#}                                     
#print "</body>";
print "</html>";





sub listPhotos
{
    my $item_uniqueID  = @_[0];
    my $item_folder    = @_[1];  
    my $itemfolderlink = @_[2];  

        		if (-e "$itemroot/$item_folder")
			{

				$cmd = "ls -1A $itemroot/$item_folder";
				my @allitemsfiles = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
				if ($?) {print OUTKFILE '<font color="red">Careful here: Listing contents of item folder has not worked! Read the gray screen output to find out why.</font>';};
				# Chopping off the line breaks from all array elements (otherwise the comparison below will not work):
				chomp(@allitemsfiles);

				foreach my $imagefilename (@allitemsfiles)
				{
		        	        # for each file that starts with a letter and ends with .jpg, .png or .gif, ignoring the case.                                 
			                if ($imagefilename =~ m/^\w.*\.(jpg|jpeg|gif|png)$/i)                                                                          
					{
						my $thumbnailfile = "$itemroot/../thumbs/$item_folder/$imagefilename";

						#create thumbnail folder if it does not exist yet:
						if (!(-e "$itemroot/../thumbs/$item_folder/."))
						{
							$cmd = "mkdir -p \"$itemroot/../thumbs/$item_folder\"";
							my @mkdirerror = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
							if ($?) {print OUTKFILE "<pre>@mkdirerror</pre> <br>\n";print OUTKFILE '<font color="red">Careful here: Creating the thumbnail folder for $imagefilename has not worked! Read the gray screen output to find out why.</font>';};
						}

						# generate thumbnail if it does not exist yet
						if (!(-e $thumbnailfile))
						{
							#`"mkdir \"$itemroot/../thumbs/$item_folder\""`;
							$cmd = "convert \"$itemroot/$item_folder/$imagefilename\" -resize x$thumbnailresolution \"$thumbnailfile\"";
							my @outputlines = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
						
							if ($?) {print OUTKFILE "<pre>@outputlines</pre> <br>\n";print OUTKFILE '<font color="red">Careful here: Converting the image has not worked! Read the gray screen output to find out why.</font>';};
						}
						else
						{
							#print OUTKFILE "thumbnail of $imagefilename already there.<br>\n"
						}
					
						# link to thumb				
						print OUTKFILE "<a href='$itemfolderlink#$imagefilename'><img border=0 src='thumbs/$item_folder/$imagefilename'></a> ";
					}
				}
			}
			else
			{
				print OUTKFILE "<a href='repairmenu.pl?itemID=$item_uniqueID'><font color='red'>Alert: The photo folder of this item was not found! Was it renamed or deleted via WebDAV? Click to repair!</font></a>";
			}


}




sub saveHistory                                                                                                                                                                                                                                                                    
{                                                                                                                                                                                                                                                                                  
    my ($givenItemID,$operation_string,$otherItemID) = @_;                                                                                                                                                                                                                         
                                                                                                                                                                                                                                                                                   
    # Double-check against implementation errors:                                                                                                                                                                                                                                  
    if ($givenItemID eq $otherItemID) {die("givenid and otherid are equal!");}                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                   
    my @itemrow = $dbh->selectrow_array("SELECT                                                                                                                                                                                                                                    
    item_folder,item_linkedfolder,item_name,item_description,item_state,item_wikiurl,item_room,item_shelf,item_currentuser,item_invoicedate,item_uniinvnum,item_category,item_versionnumber,item_serialnumber,item_workgroup,item_responsibleperson,item_uniqueID,                 
    room_id,room_number,room_floor,room_building,room_name,                                                                                                                                                                                                                        
    category_id,category_name                                                                                                                                                                                                                                                      
    FROM items LEFT JOIN rooms ON items.item_room=rooms.room_id LEFT JOIN categories ON items.item_category=categories.category_id                                                                                                                                                 
    WHERE items.item_uniqueID='$givenItemID';");                                                                                                                                                                                                                                   
    my $item_folderDB = @itemrow[0];                                                                                                                                                                                                                                               
    my $item_basedonID = @itemrow[1];                                                                                                                                                                                                                                              
    my $item_name = @itemrow[2];                                                                                                                                                                                                                                                   
    my $item_description = @itemrow[3];                                                                                                                                                                                                                                            
    my $item_state = @itemrow[4];                                                                                                                                                                                                                                                  
    my $item_wikiurl = @itemrow[5];                                                                                                                                                                                                                                                
    my $item_room = @itemrow[6];                                                                                                                                                                                                                                                   
    my $item_shelf = @itemrow[7];                                                                                                                                                                                                                                                  
    my $item_currentuser = @itemrow[8];                                                                                                                                                                                                                                            
    my $item_invoicedate = @itemrow[9];                                                                                                                                                                                                                                            
    my $item_inventorynumber = @itemrow[10];                                                                                                                                                                                                                                       
    my $item_category = @itemrow[11];                                                                                                                                                                                                                                              
    my $item_versionnumber = @itemrow[12];                                                                                                                                                                                                                                         
    my $item_serialnumber = @itemrow[13];                                                                                                                                                                                                                                          
    my $item_workgroup = @itemrow[14];                                                                                                                                                                                                                                             
    my $item_responsibleperson = @itemrow[15];                                                                                                                                                                                                                                     
    my $item_uniqueID = @itemrow[16];                                                                                                                                                                                                                                              
    my $room_id = @itemrow[17];                                                                                                                                                                                                                                                    
    my $room_number = @itemrow[18];                                                                                                                                                                                                                                                
    my $room_floor = @itemrow[19];                                                                                                                                                                                                                                                 
    my $room_building = @itemrow[20];                                                                                                                                                                                                                                              
    my $room_name = @itemrow[21];                                                                                                                                                                                                                                                  
    my $category_id = @itemrow[22];                                                                                                                                                                                                                                                
    my $category_name = @itemrow[23];                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                                                   
#    my $roomString = "Unspecified";                                                                                                                                                                                                                                               
#    if ($item_room != 0)                                                                                                                                                                                                                                                          
#    {                                                                                                                                                                                                                                                                             
#       $roomString = $room_name;                                                                                                                                                                                                                                                  
#    }                                                                                                                                                                                                                                                                             
#    my $categoryString;                                                                                                                                                                                                                                                           
                                                                           


                                                                                                                                                                                                                                                                           
    my $xmlblob = "\                                                                                                                                                                                                                                                               
        <td nowrap title=\"LDAP User\">&nbsp; by <b>WebDAV network drive</b> &nbsp;</td>\                                                                                                                                                                     
        <td nowrap title=\"Item Name\">$item_name</td> \                                                                                                                                                                                                                           
        <td nowrap title=\"Room\">$room_name</td>\                                                                                                                                                                                                                                 
        <td nowrap title=\"Shelf\">$item_shelf</td> \                                                                                                                                                                                                                              
        <td nowrap title=\"State\">$item_state</td> \                                                                                                                                                                                                                              
        <td nowrap title=\"Current User\">$item_currentuser</td> \                                                                                                                                                                                                                 
        <td nowrap title=\"-\">-</td> \                                                                                                                                                                                                                                            
        <td nowrap title=\"Responsible Person\">$item_responsibleperson</td> \                                                                                                                                                                                                     
        <td nowrap title=\"Unix Folder\">$item_folderDB</td> \                                                                                                                                                                                                                     
        <td nowrap title=\"Description\">$item_description</td> \                                                                                                                                                                                                                  
        <td nowrap title=\"LinkedItem\">$item_basedonID</td> \                                                                                                                                                                                                                     
        <td nowrap title=\"Wiki URL\">$item_wikiurl</td> \                                                                                                                                                                                                                         
        <td nowrap title=\"Invoice Date\">$item_invoicedate</td> \                                                                                                                                                                                                                 
        <td nowrap title=\"University Inventory #\">$item_inventorynumber</td> \                                                                                                                                                                                                   
        <td nowrap title=\"Serial Number\">$item_serialnumber</td> \                                                                                                                                                                                                               
        <td nowrap title=\"Version\">$item_versionnumber</td> \                                                                                                                                                                                                                    
        <td nowrap title=\"Workgroup\">$item_workgroup</td> \                                                                                                                                                                                                                      
        <td nowrap title=\"Category\">$category_name</td> \                                                                                                                                                                                                                        
        <td nowrap title=\"Item Unique ID\">$item_uniqueID</td>                                                                                                                                                                                                                    
        <td nowrap title=\"Room ID\">$item_room</td>                                                                                                                                                                                                                               
        <td nowrap title=\"Category ID\">$item_category</td>";                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                   
#    print "<table border=0><tr><td nowrap>History Blob:</td>$xmlblob</tr></table>";                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                   
    my $time = time();                                                                                                                                                                                                                                                             
    #my $ar =  $dbh->do("INSERT INTO history (history_itemuniqueid,history_operation,history_operationtime,history_xmlblob) VALUES ('$item_uniqueID','$operation_string','$time','$xmlblob')");                                                                                    
    my $ar =  $dbh->do("INSERT INTO history (history_itemuniqueid,history_operation,history_otherItemID,history_operationtime,history_xmlblob) VALUES ('$item_uniqueID','$operation_string','$otherItemID','$time','$xmlblob')");                                                  
                                                                                                                                                                                                                                                                                   
    # Do not commit here: Do it in calling code only when thte actual operation succeeded!                                                                                                                                                                                         
    #$dbh->commit();                                                                                                                                                                                                                                                               
}                                                                                                                                                                                                                                                                                  


