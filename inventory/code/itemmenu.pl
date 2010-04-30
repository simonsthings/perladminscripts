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

my $item_folder = $cgi->param('itemfolder');

my $cmd;
my $cmdoutput;

print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>ISIP Inventory Webapplication</title></head><body bgcolor='#E0E0E0'>\n";
#print "<h1>ISIP Inventory: Item Menu</h1>\n";

#my %categories;
#my $categoryname;
#my %items;

#my $inifilename = "$itemroot/$itemfolder/iteminfos.ini";
#my %itemhash;	# enth‰lt nach dem Einlesen die gesamten Daten eines Inventargegenstands
#my $hashkey; 	# speichert tempor‰r verschiedene Eigenschaftsnamen... siehe unten! 

# Den Ordner des Inventargegenstandes kennen wir schon vor dem Einlesen der ini-Datei:
#$itemhash{"itemfolder"} = $itemfolder;

# Teste, ob bereits eine ini-Datei im momentan betrachteten Verzeichnis existiert.
# Wenn ja, dann lies die ini-Datei ein.
# Wenn keine ini-datei existiert, ist der Geganstand wohl neu im Inventar.
#if (-e $inifilename)
#{
	# Wenn wir hier ankommen, heiﬂt das, dass eine ini-Datei im Verzeichnis $itemroot/$itemfolder existiert.
	# Also lies sie ein:
#	open(MYINPUTFILE, "<$inifilename"); # open for input
#	my @lines = <MYINPUTFILE>; # read file into list
#	foreach my $line (@lines) # loop thru list
#	{
		#print "$line <br>\n"; # print in sort order


		# Hier wird eine Zeile der ini-datei gescannt:
		# Der erwartete Aufbau einer Zeile ist zum Beispiel:
		# itemlocation = "Room 25"
		# wobei wir die geklammerten Teile mit hilfe des folgenden Regul‰ren Ausdrucks
		# herausfiltern:
		# (itemlocation) = "(Room 25)" 
		# Der Inhalt der ersten klammer ist nun automatisch in der 
		# variable $1 (enth‰lt dann "itemlocation") und der Inhalt der zweiten 
		# klammer ist dann in der Variable $2 (enth‰lt also "Room 25").
		# Kleine RegEx-Referenz:
		# . 	heiﬂt "ein beliebiges Zeichen" 
		# .* 	heiﬂt "beliebig oft ein beliebiges Zeichen"
		# \s	heiﬂt "ein leerzeichen"
		# \s?	heiﬂt "entweder ein oder kein Leerzeichen"
		# \"	heiﬂt Anf¸hrungszeichen (")
		# ^	heiﬂt hier "muss von Anfang an passen"
		# $	heiﬂt hier "muss ganz bis zum Ende passen"
		# (	heiﬂt hier "der nachfolgende Teil soll in einer tempor‰ren Variable gespeichert werden"
		# )	heiﬂt hier "ende der tempor‰ren variable"
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

# Kleine Ged‰chnisst¸tze f¸r mich f¸r die n‰chste groﬂe Schleife:
## categories is a hashmap.
### categoryname is a string.
### categoryitems is an array of items.
#### item is a hashmap of strings.

# Jetzt geht es an die eigentliche Ausgabe als HTML-Text!
# Wir wollen dazu f¸r jede Kategorie eine HTML-Tabelle mit den Inventargegenst‰nden ausgeben.
# Dabei soll immer ein Gegenstand pro Tabellenzeile ausgegeben werden.
# 
# Aber erstmal m¸ssen wir durch die Kategorien iterieren:
# (Da die Variable %categories kein normaler Array sondern eine Hashtabelle ist, werden
#  beim iterieren dar¸ber 2 statt 1 Schleifenvariable definiert: 
#  $categoryname ist ein String mit dem Namen der Kategorie
#  $categoryitems ist in Wirklichkeit ein Arrray der alle Items einer Kategorie enth‰lt.)
# Hier wird die aktuelle Kategorie ausgegeben:

#my $thisfolder=$itemfolder;


my @itemrow = $dbh->selectrow_array("SELECT item_folder,based_on_folder,item_name,item_description,item_state,item_wikiurl,item_room,item_shelf,current_user,item_invoicedate,item_uniinvnum,item_category,item_versionnumber,item_serialnumber FROM items WHERE item_folder='$item_folder';");

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


print "<h1>ISIP Inventory: $item_name</h1>";


## Anzeigen der Miniatur-Photos:
#
# Die HTML-Zeile soll anklickbar sein, also m¸ssen wir den HTML-Link vorbereiten:
#my $itemlink = "/items/$item_folder/dummy";
my @otheritemfilenames;

$cmd = "ls -1A $itemroot/$item_folder";
my @allitemsfiles = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};
# Chopping off the line breaks from all array elements (otherwise the comparison below will not work):
chomp(@allitemsfiles);

foreach my $imagefilename (@allitemsfiles)
{
	if ((substr($imagefilename, -4) eq (".jpg")) or (substr($imagefilename, -4) eq (".png")) or (substr($imagefilename, -4) eq (".gif")))
	{
		my $thumbnailfile = "$itemroot/../thumbs/$item_folder/$imagefilename";

		# generate thumbnail if it does not exist yet
		if (!(-e $thumbnailfile))
		{
			`mkdir $itemroot/../thumbs/$item_folder`;
			$cmd = "convert $itemroot/$item_folder/$imagefilename -resize x30 $thumbnailfile";
			my @outputlines = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.

			if ($?) {print "<pre>@outputlines</pre> <br>\n";print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};
		}
		else
		{
			#print "thumbnail of $imagefilename already there.<br>\n"
		}

		# link to thumb				
		print "<a href='items/$item_folder/$imagefilename'><img border=0 src='thumbs/$item_folder/$imagefilename'></a> ";
	}
	else
	{
		push (@otheritemfilenames, $imagefilename);
		#print "Other file: $imagefilename ";
	}
}
## Ende der photos



# Dann kommt eine HTML-Tabelle, die die ganzen Inventargegenst‰nde dieser Kategorie
# enth‰lt. Erst kommen die ‹berschriften, ...
print "<form action='/saveitem.pl' method='get'>\n";

print "Things that don't change:";
print "<table border=1>";
print "<tr><th>Item Name</th><td><input type='text' name='item_name' value='$item_name'><font size='2'>(unix folder: \"$item_folder\", based on \"$item_basedon\")</font></td></tr>";
print "<tr><th>Version Number</th><td><input type='text' name='item_versionnumber' value='$item_versionnumber'> (e.g. Board Revision or software version or ISBN or DOI)</td></tr>";
print "<tr><th>Serial Number</th><td><input type='text' name='item_serialnumber' value='$item_serialnumber'> (hardware serial number or software key: identifies otherwise identical objects!)</td></tr>";
print "<tr><th>Category</th><td><select name='item_category' size='1'>";
#print "<option value=0>Other (use location field)</option>";
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
print "<tr><th>Item Description</th><td><textarea rows=8 cols='60'  name='item_description' >$item_description</textarea></td></tr>";
print "<tr><th>ISIP Wiki URL (<a href='$item_wikiurl'>visit</a>)</th><td><input type='text' name='item_wikiurl' value='$item_wikiurl'> (copy&paste URL here) </td></tr>";
print "<tr><th>Inventory Number</th><td><input type='text' name='item_inventorynumber' value='$item_inventorynumber'> (the official inventory number assigned by the university)</td></tr>";
print "<tr><th>Invoice Date</th><td><input type='text' name='item_invoicedate' value='$item_invoicedate'> (german: Rechnungsdatum. Might be important for repairs!)</td></tr>";
print "</table>";

print "<br><br>Things that change:";

print "<table border=1>";   
print "<tr><th>Item State</th><td>";
my $statestring = "";
if ($item_state eq "Functional") {$statestring = "checked";}
else {$statestring = "";}
print "    <input type=\"radio\" name=\"item_state\" value=\"Functional\" $statestring> Functional";
if ($item_state eq "Partly Functional") {$statestring = "checked";}                                                                                  
else {$statestring = "";} 
print "    <input type=\"radio\" name=\"item_state\" value=\"Partly Functional\" $statestring> Partly Functional";
if ($item_state eq "Destroyed") {$statestring = "checked";}                                                                                  
else {$statestring = "";} 
print "    <input type=\"radio\" name=\"item_state\" value=\"Destroyed\" $statestring> Destroyed";
print " </td></tr>";
print "<tr><th>Location</th><td><select name='item_room' size='1'>";
print "<option value=0>Other (use secret map field)</option>";
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
print "</select><br><b>Shelf, box, or secret map: </b> <input type='text' size='45' name='item_shelf' value='$item_shelf'</td></tr>";
print "<tr><th>Current User</th><td><input size=40 type='text' name='item_currentuser' value='$item_currentuser'> (the name & email of current user)</td></tr>";
print "</table>";

print "    <input type='hidden' name='item_folder' value='$item_folder'>\n";
print "    <input type='hidden' name='item_basedon' value='$item_basedon'>\n";
print "    <input type='hidden' name='item_category' value='$item_category'>\n";
print "    <br><input type='submit' value='Save!'>";
print "<a href='/'>Back to List</a>";

print "</form>";

if (@otheritemfilenames)
{
	print "<h3>Other files:</h3>";
	foreach my $otherfilename (@otheritemfilenames)
	{
		print "$otherfilename<br>\n";
	}
}

print "</body></html>\n";

