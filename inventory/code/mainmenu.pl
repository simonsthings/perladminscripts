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

my $cmd;
my $cmdoutput;

print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>ISIP Inventory Webapplication</title></head><body bgcolor='#E0E0E0'>\n";
print "<h1>ISIP Inventory App</h1>\n";
print "(Mount <a href='https://inventory.isip.uni-luebeck.de/items/'>https://inventory.isip.uni-luebeck.de/items/</a> as a network drive for uploading images via WebDAV.)<br>\n";
print "<br>\n";

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

### Create DB rows for new item folders:
foreach my $itemfolder (@allitemfolders) 
{
	$sth->execute($itemfolder);

	my $existsInDB = 0;
	while(my @row = $sth->fetchrow_array())
	{
	$existsInDB = 1;
	#print "The folder $itemfolder is already in the database.\n";
	#print "$row[0], $row[2], $row[3]\n";
	}

	if (!$existsInDB)
	{
	    # check if this is really a directory and if it contains valid characters: m/^\w(\w|\.)+$/
	    if (-d "$itemroot/$itemfolder")
		{
		    if ( $itemfolder =~ m/^\w(\w|\.)+$/ )
		    {
				my $rv = $dbh->do("INSERT INTO items (item_folder,item_name,item_description) VALUES ('$itemfolder','$itemfolder','...')");
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

print "<h2>These items exist in the inventory database:</h2>\n";
# Get all items (or gt only one category here later when implemented via CGI parameter) 
my $allitemrowsref = $dbh->selectall_arrayref("SELECT item_folder,based_on_folder,item_name,item_description,item_state,item_wikiurl,item_room,item_shelf,current_user,item_invoicedate,item_uniinvnum,item_category FROM items");
# Die Datenbank wird ab jetzt nicht mehr gebraucht. Also wird sie geschlossen:
$dbh->disconnect();

# Jetzt geht es an die eigentliche Ausgabe als HTML-Text!
# Wir wollen dazu für jede Kategorie eine HTML-Tabelle mit den Inventargegenständen ausgeben.
# Dabei soll immer ein Gegenstand pro Tabellenzeile ausgegeben werden.
# 
# Aber erstmal müssen wir durch die Kategorien iterieren:
# (Da die Variable %categories kein normaler Array sondern eine Hashtabelle ist, werden
#  beim iterieren darüber 2 statt 1 Schleifenvariable definiert: 
#  $categoryname ist ein String mit dem Namen der Kategorie
#  $categoryitems ist in Wirklichkeit ein Arrray der alle Items einer Kategorie enthält.)
#while (my ($categoryname, $categoryitems) = each(%categories))
#{
	# Hier wird die aktuelle Kategorie ausgegeben:
#	print "<h3>Category: $categoryname</h3>";
	
	# Dann kommt eine HTML-Tabelle, die die ganzen Inventargegenstände dieser Kategorie
	# enthält. Erst kommen die Überschriften, ...
	print "<table border=1>";
	print "<tr>";
	print "<th>Item Name</th>";
	print "<th>Photos</th>";
	print "<th>Room</th>";
	print "<th>Folder</th>";
	print "</tr>";
	# ... dann kommen die eigentlichen Inventurgegenstände.
	# Mit @{$categoryitems} sagen wir Perl, dass die Variable $categoryitems in Wirklichkeit 
	# ein Array ist (markiert durch das @-Zeichen), damit wir darüber iterieren können.
#	foreach my $oneItem (@{$categoryitems})
	foreach my $itemrowref (@{$allitemrowsref})
	{
		my @itemrow = @{$itemrowref};

		# Hier teilen wir Perl mit, dass die arrayvariable $oneItem in Wirklichkeit 
		# ein Zeiger auf eine Hash-Tabelle war (gekennzeichnet durch das %-Zeichen). 
		# Wir geben hier außerdem dieser Hash-tabelle einen neuen Namen, nämlich %thisitem. 
		# Weil sie nämlich die Eigenschaften des aktuell ausgegebenen Inventargegenstandes
		# für die HTML-Tabelle enthält.
#		my %thisitem = %{$oneItem};
		
		# Zum einfacheren Umgang: 
#		my $thisfolder = $thisitem{"itemfolder"};
		my $item_folder = @itemrow[0];

		my $item_name = @itemrow[2];
		my $item_description = @itemrow[3];
		my $item_room = @itemrow[6];

		# Die HTML-Zeile soll anklickbar sein, also müssen wir den HTML-Link vorbereiten:
		my $itemfolderlink = "itemmenu.pl?itemfolder=$item_folder";
		
		# Hier wird dann die eigentliche Zeile der HTML-Tabelle ausgegeben:
		print "<tr>\n";
		print "<td width=50><a href='$itemfolderlink'>$item_name</a></td>\n";
		print "<td>\n";
		
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
					$cmd = "convert \"$itemroot/$item_folder/$imagefilename\" -resize x48 \"$thumbnailfile\"";
					my @outputlines = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
					
					if ($?) {print "<pre>@outputlines</pre> <br>\n";print '<font color="red">Careful here: Converting the image has not worked! Read the gray screen output to find out why.</font>';};
				}
				else
				{
					#print "thumbnail of $imagefilename already there.<br>\n"
				}
				
				# link to thumb				
				print "<a href='$itemfolderlink#$imagefilename'><img border=0 src='thumbs/$item_folder/$imagefilename'></a>";
			}
		}

		#print "@allitemsfiles";
		print "</td>\n";
		print "<td><a href='$itemfolderlink'>$item_room</a></td>\n";
		print "<td><a href='$itemfolderlink'>$item_folder</a></td>\n";
		print "</tr>\n";
	}
	print "</table>";
#}
print "</body></html>\n";

