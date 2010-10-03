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

my $cgi_item_folder = $cgi->param('itemfolder');
my $cgi_item_uniqueID = $cgi->param('itemID');

my $cmd;
my $cmdoutput;

print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>LabTracker - Item Menu</title></head><body bgcolor='#E0E0E0'>\n";
print "<font FACE='Helvetica, Arial, Verdana, Tahoma'>";
#print "<h1>ISIP Inventory: Item Menu</h1>\n";

#my %categories;
#my $categoryname;
#my %items;

#my $inifilename = "$itemroot/$itemfolder/iteminfos.ini";
#my %itemhash;	# enthält nach dem Einlesen die gesamten Daten eines Inventargegenstands
#my $hashkey; 	# speichert temporär verschiedene Eigenschaftsnamen... siehe unten! 

# Den Ordner des Inventargegenstandes kennen wir schon vor dem Einlesen der ini-Datei:
#$itemhash{"itemfolder"} = $itemfolder;

# Teste, ob bereits eine ini-Datei im momentan betrachteten Verzeichnis existiert.
# Wenn ja, dann lies die ini-Datei ein.
# Wenn keine ini-datei existiert, ist der Geganstand wohl neu im Inventar.
#if (-e $inifilename)
#{
	# Wenn wir hier ankommen, heißt das, dass eine ini-Datei im Verzeichnis $itemroot/$itemfolder existiert.
	# Also lies sie ein:
#	open(MYINPUTFILE, "<$inifilename"); # open for input
#	my @lines = <MYINPUTFILE>; # read file into list
#	foreach my $line (@lines) # loop thru list
#	{
		#print "$line <br>\n"; # print in sort order


		# Hier wird eine Zeile der ini-datei gescannt:
		# Der erwartete Aufbau einer Zeile ist zum Beispiel:
		# itemlocation = "Room 25"
		# wobei wir die geklammerten Teile mit hilfe des folgenden Regulären Ausdrucks
		# herausfiltern:
		# (itemlocation) = "(Room 25)" 
		# Der Inhalt der ersten klammer ist nun automatisch in der 
		# variable $1 (enthält dann "itemlocation") und der Inhalt der zweiten 
		# klammer ist dann in der Variable $2 (enthält also "Room 25").
		# Kleine RegEx-Referenz:
		# . 	heißt "ein beliebiges Zeichen" 
		# .* 	heißt "beliebig oft ein beliebiges Zeichen"
		# \s	heißt "ein leerzeichen"
		# \s?	heißt "entweder ein oder kein Leerzeichen"
		# \"	heißt Anführungszeichen (")
		# ^	heißt hier "muss von Anfang an passen"
		# $	heißt hier "muss ganz bis zum Ende passen"
		# (	heißt hier "der nachfolgende Teil soll in einer temporären Variable gespeichert werden"
		# )	heißt hier "ende der temporären variable"
		#
		#
		## Flexiblerer Ansatz:
#		if ( $line =~ /^(.*)\s=\s\"(.*)\"$/g )
#		{
#			$itemhash{$1} = $2;
#		}
		

		## Lesbarer Ansatz:

		#$hashkey = "itemcategory";
		#if ( $line =~ /^$hashkey\s=\s\"(.*)\"$/g )
		#{
		#	$itemhash{$hashkey} = $1;
		#}
		#
		#$hashkey = "itemlocation";
		#if ( $line =~ /^$hashkey\s=\s\"(.*)\"$/g )
		#{
		#	$itemhash{$hashkey} = $1;
		#}
		#
		#$hashkey = "itemname";
		#if ( $line =~ /^$hashkey\s=\s\"(.*)\"$/g )
		#{
		#	$itemhash{$hashkey} = $1;
		#}
		#
		#$hashkey = "itemuser";
		#if ( $line =~ /^$hashkey\s=\s\"(.*)\"$/g )
		#{
		#	$itemhash{$hashkey} = $1;
		#}


#	}
#	close(MYINPUTFILE);
#}
#else # ...Wenn also keine .ini-datei gefunden wurde:
#{
	# add to category "new"
#	$itemhash{"itemcategory"} = "-new-";
#	$itemhash{"itemlocation"} = "-new-";
#	$itemhash{"itemname"} = "-new-";
#	$itemhash{"itemuser"} = "-new-";
	#$categoryname = $itemhash{itemcategory};
#}

#print "ITEMcategory   key= -itemcategory- ...value= -$itemhash{itemcategory}- <br>\n";
#$items{$itemfolder} = \%itemhash;

#$categoryname = $itemhash{"itemcategory"};
#push(@{$categories{$categoryname}} , \%itemhash);



# ...hier sollten vielleicht noch irgendwo die Categories sortiert werden...

# Kleine Gedächnisstütze für mich für die nächste große Schleife:
## categories is a hashmap.
### categoryname is a string.
### categoryitems is an array of items.
#### item is a hashmap of strings.

# Jetzt geht es an die eigentliche Ausgabe als HTML-Text!
# Wir wollen dazu für jede Kategorie eine HTML-Tabelle mit den Inventargegenständen ausgeben.
# Dabei soll immer ein Gegenstand pro Tabellenzeile ausgegeben werden.
# 
# Aber erstmal müssen wir durch die Kategorien iterieren:
# (Da die Variable %categories kein normaler Array sondern eine Hashtabelle ist, werden
#  beim iterieren darüber 2 statt 1 Schleifenvariable definiert: 
#  $categoryname ist ein String mit dem Namen der Kategorie
#  $categoryitems ist in Wirklichkeit ein Arrray der alle Items einer Kategorie enthält.)
# Hier wird die aktuelle Kategorie ausgegeben:

#my $thisfolder=$itemfolder;

my $wherecondition;
if ($cgi_item_uniqueID eq "")
{
    $wherecondition = "WHERE item_folder='$cgi_item_folder'";
    print "<font color=grey>Notice: Using the item folder to specify the item to edit is deprecated and will stop working soon.</font><br>\n"
}
else
{
    $wherecondition = "WHERE item_uniqueID='$cgi_item_uniqueID'";
}
my @itemrow = $dbh->selectrow_array("SELECT item_folder,item_linkedfolder,item_name,item_description,item_state,item_wikiurl,item_room,item_shelf,item_currentuser,item_invoicedate,item_uniinvnum,item_category,item_versionnumber,item_serialnumber,item_workgroup,item_responsibleperson,item_uniqueID  FROM items  $wherecondition ;");
#print "Item row: @itemrow";
#die("Only one element was returned while asking the database for a complete row of item data! Please check SQL query (to changed schema?) and update implementation!") unless (@itemrow > 1);

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
my $item_inventorynumber = @itemrow[10];
my $item_category = @itemrow[11];
my $item_versionnumber = @itemrow[12];
my $item_serialnumber = @itemrow[13];
my $item_workgroup = @itemrow[14];
my $item_responsibleperson = @itemrow[15];
my $item_uniqueID = @itemrow[16];

if (@itemrow > 0)
{
    print "<table border=0 width=100%><tr><td>";
    print "<h1>$item_name</h1>";
    print "</td><td align=right valign=top>";
    my $prev = $cgi_item_uniqueID - 1;
    my $next = $cgi_item_uniqueID + 1;
    if ($prev==0){$prev=1;}
    print "    <a href=\"/itemmenu.pl?itemID=$prev\"><font color=grey>Previous</font></a> <font color=grey> | </font>  ";
    print "    <a href=\"/itemmenu.pl?itemID=$next\"><font color=grey>Next</font></a> ";
    print "</td></tr></table>";
}
else
{
    print "<table border=0 width=100%><tr><td>";
    print "<h1>There is no item $cgi_item_uniqueID. Go away!</h1>";
    print "</td><td align=right valign=top>";
    my $prev = $cgi_item_uniqueID - 1;
    my $next = $cgi_item_uniqueID + 1;
    if ($prev==0){$prev=1;}
    print "    <a href=\"/itemmenu.pl?itemID=$prev\"><font color=grey>Previous</font></a> <font color=grey> | </font>  ";
    print "    <a href=\"/itemmenu.pl?itemID=$next\"><font color=grey>Next</font></a> ";
    print "</td></tr></table>";
    
    # History:
#    print "<u>Item History:</u><br>";
    print "<iframe src=\"historylist.pl?itemID=$cgi_item_uniqueID\" name=\"historyiframe\" width=\"100%\" frameborder=0 marginheight=3 marginwidth=0>";
    print "Your browser does not support iframes! Please just visit <A HREF=\"historylist.pl\">this page</A> instead.";                            
    print "</iframe>\n";
    print "<br>\n\n";
    
    print "</body></html>";
    exit 0;
}

# see sub-procedure at end of file.
showPhotos();


my $fieldhelpfontsize = 1;
# Dann kommt eine HTML-Tabelle, die die ganzen Inventargegenstände dieser Kategorie
# enthält. Erst kommen die Überschriften, ...
print "<form action='/folderoperations.pl' method='get'>\n";

# Save button:
print "  <input type='submit' value='Save & Back'>";
print "  <input type='submit' value='Save & Stay'>";
print "  <a href=\"/mainmenu.pl?itemID=$item_uniqueID\">Cancel</a> ";
#print "	<input type='button' value='Cancel' onclick='document.location.href=\"/#$item_folder\"'>";


print "<br><br>";


print "Things that don't change:";
print "<TABLE BORDER=1 rules='rows' CELLSPACING=0 CELLPADDING=0 width='100%' BORDERCOLOR='darkgrey'>";

print "<tr><th bgcolor='#6b7f93'><font color='white'>Item Name</font></th><td bgcolor='white'><input type='text' name='item_name' value='$item_name'>";
if ($item_basedon eq "")
{
print "<font size='$fieldhelpfontsize'> (unix folder: \"$item_folder\", linked to no other item's folder)</font> ";
}
else
{
print "<font size='$fieldhelpfontsize'> (unix folder: \"$item_folder\", based on item <a href='itemmenu.pl?itemID=$item_basedon'>$item_basedon</a>)</font> ";
}
#print "<input type='button' value='Rename unix folder' onclick='document.location.href=\"/style/notimplemented.html\"' disabled>";
print "<input type='button' value='Change linked item' onclick='document.location.href=\"/style/notimplemented.html\"' disabled> ";
print "</td></tr>";

print "<tr><th bgcolor='#6b7f93'><font color='white'>Version / Model</font></th><td bgcolor='white'><input type='text' name='item_versionnumber' value='$item_versionnumber'><font size='$fieldhelpfontsize'> (e.g. Board Revision or software version or ISBN or DOI)</font></td></tr>";

print "<tr><th bgcolor='#6b7f93'><font color='white'>Serial Number</font></th><td bgcolor='white'><input type='text' name='item_serialnumber' value='$item_serialnumber'><font size='$fieldhelpfontsize'> (hardware serial number or software key: identifies otherwise identical objects!)</font></td></tr>";
print "<tr><th bgcolor='#6b7f93'><font color='white'>Category</font></th><td bgcolor='white'><select name='item_category' size='1'>";
my $allroomrowsref = $dbh->selectall_arrayref("SELECT category_id,category_name FROM categories");
	foreach my $roomrowref (@{$allroomrowsref})
	{
		my @roomrow = @{$roomrowref};

		my $category_id = @roomrow[0];
		my $category_name = @roomrow[1];

		my $isselected = "";
		if ($category_id eq $item_category) {$isselected = "selected";}
		print "<option value=$category_id $isselected>$category_name</option>";
	}
print "</select></td></tr>";
print "<tr><th width=200 bgcolor='#6b7f93'><font color='white'>Item Description</font></th><td bgcolor='white'><textarea rows=8 cols='60'  name='item_description' >$item_description</textarea></td></tr>";
print "<tr><th bgcolor='#6b7f93'><font color='white'>ISIP Wiki URL (<a href='$item_wikiurl'>visit</a>)</font></th><td bgcolor='white'><input type='text' name='item_wikiurl' value='$item_wikiurl'><font size='$fieldhelpfontsize'> (copy&paste URL here) </font></td></tr>";
print "<tr><th bgcolor='#6b7f93'><font color='white'>Inventory Number</font></th><td bgcolor='white'><input type='text' name='item_inventorynumber' value='$item_inventorynumber'><font size='$fieldhelpfontsize'> (the official inventory number assigned by the university) </font></td></tr>";
print "<tr><th bgcolor='#6b7f93'><font color='white'>Invoice Date</font></th><td bgcolor='white'><input type='text' name='item_invoicedate' value='$item_invoicedate'><font size='$fieldhelpfontsize'> (german: Rechnungsdatum. Might be important for repairs!) </font></td></tr>";
# Workgroup & Who to ask:
print "<tr><th bgcolor='#6b7f93'><font color='white'>Workgroup & Owner</font></th><td bgcolor='white'><select name='item_workgroup' size='1'>";
{
my $isselected;
if ($item_workgroup eq "Uli") {$isselected = "selected";} else {$isselected = "";}
print "<option value='Uli' $isselected>Uli</option>";
if ($item_workgroup eq "Alfred") {$isselected = "selected";} else {$isselected = "";}
print "<option value='Alfred' $isselected>Alfred</option>";
}
print "</select> <b>Who to Ask about it:</b><input type='text' size=15 name='item_responsibleperson' value='$item_responsibleperson'><font size='$fieldhelpfontsize'> (member of ISIP staff) </font></td></tr>";
print "</table>";

print "<br>Things that change:";

print "<TABLE BORDER=1 rules='rows' CELLSPACING=0 CELLPADDING=0 width='100%' BORDERCOLOR='darkgrey'>";
# item state:
print "<tr><th width=200 bgcolor='#6b7f93'><font color='white'>Item State</font></th><td bgcolor='white'>";
my $statestring = "";
if ($item_state eq "Functional") {$statestring = "checked";} else {$statestring = "";}
print "    <input type=\"radio\" name=\"item_state\" value=\"Functional\" $statestring> Functional";
if ($item_state eq "Partly Functional") {$statestring = "checked";} else {$statestring = "";} 
print "    <input type=\"radio\" name=\"item_state\" value=\"Partly Functional\" $statestring> Partly Functional";
if ($item_state eq "Destroyed") {$statestring = "checked";} else {$statestring = "";} 
print "    <input type=\"radio\" name=\"item_state\" value=\"Destroyed\" $statestring> Destroyed";
print " </td></tr>";
# item location:
print "<tr><th bgcolor='#6b7f93'><font color='white'>Location</font></th><td bgcolor='white'><select name='item_room' size='1'>";
print "<option value=0>Other (specify below)</option>";
my $allroomrowsref = $dbh->selectall_arrayref("SELECT room_id,room_number,room_floor,room_building,room_name FROM rooms");
foreach my $roomrowref (@{$allroomrowsref})
{
	my @roomrow = @{$roomrowref};

	my $room_id = @roomrow[0];
	my $room_number = @roomrow[1];
	my $room_floor = @roomrow[2];
	my $room_building = @roomrow[3];
	my $room_name = @roomrow[4];

	my $isselected = "";
	if ($room_id eq $item_room) {$isselected = "selected";}
	print "<option value=$room_id $isselected>$room_name ($room_building, Floor $room_floor, Room $room_number)</option>";
}
print "</select><br><input type='text' size='45' name='item_shelf' value='$item_shelf'><font size='$fieldhelpfontsize'> (shelf, box, or secret map) </font></td></tr>";
# item user:
print "<tr><th bgcolor='#6b7f93'><font color='white'>Current User (Email)</font></th><td bgcolor='white'><input size=40 type='text' name='item_currentuser' value='$item_currentuser'><font size='$fieldhelpfontsize'> (e.g. email of current user / student) </font></td></tr>";
print "</table>";

print "    <input type='hidden' name='item_folder' value='$item_folder'>\n";
print "    <input type='hidden' name='item_basedon' value='$item_basedon'>\n";
print "    <input type='hidden' name='itemID' value='$item_uniqueID'>\n";
print "    <input type='hidden' name='itemaction' value='editsave'>\n";
#print "    <input type='hidden' name='item_category' value='$item_category'>\n";


# Save button:
print "    <br><input type='submit' value='Save & Back'>";
print "        <input type='submit' value='Save & Stay'>";
print "    <a href=\"/mainmenu.pl?itemID=$item_uniqueID\">Cancel</a> ";
#print "	<input type='button' value='Cancel' onclick='document.location.href=\"/#$item_folder\"'>";
# End of form
print "</form>";


# History:
print "<u>Item History:</u><br>";
print "<iframe src=\"historylist.pl?itemID=$item_uniqueID\" name=\"historyiframe\" width=\"100%\" height=\"100\" frameborder=0 marginheight=3 marginwidth=0>";                                                                      
print "Your browser does not support iframes! Please just visit <A HREF=\"historylist.pl\">this page</A> instead.";                            
print "</iframe>\n";
print "<br>\n\n";



# Delete Button:
print "<br>\n";
print "<input type='button' value='Delete this item...' onclick='document.location.href=\"/deleteitem.pl?itemID=$cgi_item_uniqueID\"'>";


# WebDAV hint:
print "<br>\n";
print "<br>\n";
print "The WebDAV folder for uploading files for this item is currently:<br><a href='https://inventory.isip.uni-luebeck.de/items/$item_folder/'' >https://inventory.isip.uni-luebeck.de/items/$item_folder/</a>"; 

print "</body></html>\n";





sub showPhotos
{

    ## Anzeigen der Miniatur-Photos:
    #
    # Die HTML-Zeile soll anklickbar sein, also müssen wir den HTML-Link vorbereiten:

    print "<u>Photos (click them!):</u><br>";

    my $thumbnailresolution = 200;
    my @otheritemfilenames;

    if (-e "$itemroot/$item_folder")
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
			my $thumbnailfile = "$itemroot/../thumbs/$item_folder/${thumbnailresolution}px-$imagefilename";

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
			print "<a href='images/$item_folder/$imagefilename'><img border=0 src='thumbs/$item_folder/${thumbnailresolution}px-$imagefilename'></a> ";
			
			# Increase photo counter:
			$numberofImages = $numberofImages + 1;
		}
		else
		{
			push (@otheritemfilenames, $imagefilename);
			#print "Other file: $imagefilename ";
		}
	}
	if ($numberofImages == 0)
	{
	    print "<font color='grey'>none.</font>\n";
	}
    }
    else
    {
	print "<font color='red'>Alert: The photo folder of this item was not found! Was is renamed or deleted via WebDAV? Click to repair!</font>";
    }
    ## Ende der photos



    ## Andere Dateien:
    print "<br><br><u>Other files:</u><br>";

    if (@otheritemfilenames)
    {
    #	print "<h3>Other files:</h3>";
	foreach my $otherfilename (@otheritemfilenames)
	{
		#chomp ($otherfilename);
		print "<a href='items/$item_folder/$otherfilename'><font color='grey'>$otherfilename</font></a><br>\n";
	}
    }
    else
    {
	print "<font color='grey'>none.</font><br>\n";
    }
    
    print "<br>\n";

}