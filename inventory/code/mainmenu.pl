#!/usr/bin/perl -w

use strict;
use CGI;
my $cgi = new CGI;
use CGI::Carp qw(fatalsToBrowser);

my $itemroot = "/var/www/inventory/items";

my $cmd;
my $cmdoutput;

print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">', "\n";
print "<html><head><title>ISIP Inventory Webapplication</title></head><body bgcolor='#E0E0E0'>\n";
print "<h1>ISIP Inventory App</h1>\n";


$cmd = "ls -1A $itemroot/";
my @allitemfolders = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};

# Chopping off the line breaks from all array elements (otherwise the comparison below will not work):
chomp(@allitemfolders);

my %categories;
my $categoryname;
my %items;
foreach my $itemfolder (@allitemfolders) 
{
	my $inifilename = "$itemroot/$itemfolder/iteminfos.ini";
	my %itemhash;	# enth�lt nach dem Einlesen die gesamten Daten eines Inventargegenstands
	my $hashkey; 	# speichert tempor�r verschiedene Eigenschaftsnamen... siehe unten! 
	
	# Den Ordner des Inventargegenstandes kennen wir schon vor dem Einlesen der ini-Datei:
	$itemhash{"itemfolder"} = $itemfolder;
	
	# Teste, ob bereits eine ini-Datei im momentan betrachteten Verzeichnis existiert.
	# Wenn ja, dann lies die ini-Datei ein.
	# Wenn keine ini-datei existiert, ist der Geganstand wohl neu im Inventar.
	if (-e $inifilename)
	{
		# Wenn wir hier ankommen, hei�t das, dass eine ini-Datei im Verzeichnis $itemroot/$itemfolder existiert.
		# Also lies sie ein:
		open(MYINPUTFILE, "<$inifilename"); # open for input
		my @lines = <MYINPUTFILE>; # read file into list
		foreach my $line (@lines) # loop thru list
		{
			#print "$line <br>\n"; # print in sort order
			
			
			# Hier wird eine Zeile der ini-datei gescannt:
			# Der erwartete Aufbau einer Zeile ist zum Beispiel:
			# itemlocation = "Room 25"
			# wobei wir die geklammerten Teile mit hilfe des folgenden Regul�ren Ausdrucks
			# herausfiltern:
			# (itemlocation) = "(Room 25)" 
			# Der Inhalt der ersten klammer ist nun automatisch in der 
			# variable $1 (enth�lt dann "itemlocation") und der Inhalt der zweiten 
			# klammer ist dann in der Variable $2 (enth�lt also "Room 25").
			# Kleine RegEx-Referenz:
			# . 	hei�t "ein beliebiges Zeichen" 
			# .* 	hei�t "beliebig oft ein beliebiges Zeichen"
			# \s	hei�t "ein leerzeichen"
			# \s?	hei�t "entweder ein oder kein Leerzeichen"
			# \"	hei�t Anf�hrungszeichen (")
			# ^	hei�t hier "muss von Anfang an passen"
			# $	hei�t hier "muss ganz bis zum Ende passen"
			# (	hei�t hier "der nachfolgende Teil soll in einer tempor�ren Variable gespeichert werden"
			# )	hei�t hier "ende der tempor�ren variable"
			#
			#
			## Flexiblerer Ansatz:
			if ( $line =~ /^(.*)\s=\s\"(.*)\"$/g )
			{
				$itemhash{$1} = $2;
			}
			

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


		}
		close(MYINPUTFILE);
	}
	else # ...Wenn also keine .ini-datei gefunden wurde:
	{
		# add to category "new"
		$itemhash{"itemcategory"} = "-new-";
		$itemhash{"itemroom"} = "-new-";
		$itemhash{"itemname"} = "-new-";
		$itemhash{"itemuser"} = "-new-";
		#$categoryname = $itemhash{itemcategory};
	}
	
	#print "ITEMcategory   key= -itemcategory- ...value= -$itemhash{itemcategory}- <br>\n";
	#$items{$itemfolder} = \%itemhash;
	
	$categoryname = $itemhash{"itemcategory"};
	push(@{$categories{$categoryname}} , \%itemhash);
}


# ...hier sollten vielleicht noch irgendwo die Categories sortiert werden...

# Kleine Ged�chnisst�tze f�r mich f�r die n�chste gro�e Schleife:
## categories is a hashmap.
### categoryname is a string.
### categoryitems is an array of items.
#### item is a hashmap of strings.

# Jetzt geht es an die eigentliche Ausgabe als HTML-Text!
# Wir wollen dazu f�r jede Kategorie eine HTML-Tabelle mit den Inventargegenst�nden ausgeben.
# Dabei soll immer ein Gegenstand pro Tabellenzeile ausgegeben werden.
# 
# Aber erstmal m�ssen wir durch die Kategorien iterieren:
# (Da die Variable %categories kein normaler Array sondern eine Hashtabelle ist, werden
#  beim iterieren dar�ber 2 statt 1 Schleifenvariable definiert: 
#  $categoryname ist ein String mit dem Namen der Kategorie
#  $categoryitems ist in Wirklichkeit ein Arrray der alle Items einer Kategorie enth�lt.)
while (my ($categoryname, $categoryitems) = each(%categories))
{
	# Hier wird die aktuelle Kategorie ausgegeben:
	print "<h3>Category: $categoryname</h3>";
	
	# Dann kommt eine HTML-Tabelle, die die ganzen Inventargegenst�nde dieser Kategorie
	# enth�lt. Erst kommen die �berschriften, ...
	print "<table border=1>";
	print "<tr>";
	print "<th>Item Name</th>";
	print "<th>Room</th>";
	print "<th>Photos</th>";
	print "<th>Folder</th>";
	print "</tr>";
	# ... dann kommen die eigentlichen Inventurgegenst�nde.
	# Mit @{$categoryitems} sagen wir Perl, dass die Variable $categoryitems in Wirklichkeit 
	# ein Array ist (markiert durch das @-Zeichen), damit wir dar�ber iterieren k�nnen.
	foreach my $oneItem (@{$categoryitems})
	{
		# Hier teilen wir Perl mit, dass die arrayvariable $oneItem in Wirklichkeit 
		# ein Zeiger auf eine Hash-Tabelle war (gekennzeichnet durch das %-Zeichen). 
		# Wir geben hier au�erdem dieser Hash-tabelle einen neuen Namen, n�mlich %thisitem. 
		# Weil sie n�mlich die Eigenschaften des aktuell ausgegebenen Inventargegenstandes
		# f�r die HTML-Tabelle enth�lt.
		my %thisitem = %{$oneItem};
		
		# Zum einfacheren Umgang: 
		my $thisfolder = $thisitem{"itemfolder"};
		
		# Die HTML-Zeile soll anklickbar sein, also m�ssen wir den HTML-Link vorbereiten:
		my $itemlink = "itemmenu.pl?itemfolder=$thisfolder";
		
		# Hier wird dann die eigentliche Zeile der HTML-Tabelle ausgegeben:
		print "<tr>\n";
		print "<td><a href='$itemlink'>$thisitem{itemname}</a></td>\n";
		print "<td><a href='$itemlink'>$thisitem{itemroom}</a></td>\n";
		print "<td>\n";
		
		$cmd = "ls -1A $itemroot/$thisfolder";
		my @allitemsfiles = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
		if ($?) {print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};
		# Chopping off the line breaks from all array elements (otherwise the comparison below will not work):
		chomp(@allitemsfiles);

		foreach my $imagefilename (@allitemsfiles)
		{
			if ((substr($imagefilename, -4) eq (".jpg")) or (substr($imagefilename, -4) eq (".png")) or (substr($imagefilename, -4) eq (".gif")))
			{
				my $thumbnailfile = "$itemroot/../thumbs/$thisfolder/$imagefilename";
				
				# generate thumbnail if it does not exist yet
				if (!(-e $thumbnailfile))
				{
					`mkdir $itemroot/../thumbs/$thisfolder`;
					$cmd = "convert $itemroot/$thisfolder/$imagefilename -resize x30 $thumbnailfile";
					my @outputlines = `$cmd 2>&1`;  # The 2>&1 makes all screen output be written to the web page.
					
					if ($?) {print "<pre>@outputlines</pre> <br>\n";print '<font color="red">Careful here: It seems that the above command has not worked! Read the gray screen output to find out why.</font>';};
				}
				else
				{
					#print "thumbnail of $imagefilename already there.<br>\n"
				}
				
				# link to thumb				
				print "<a href='$itemlink#$imagefilename'><img border=0 src='http://auxus.isip.uni-luebeck.de:80/inventory/thumbs/$thisfolder/$imagefilename'></a>";
			}
		}

		#print "@allitemsfiles";
		print "</td>\n";
		print "<td><a href='$itemlink'>$thisitem{itemfolder}</a></td>\n";
		print "</tr>\n";
	}
	print "</table>";
}
print "</body></html>\n";

