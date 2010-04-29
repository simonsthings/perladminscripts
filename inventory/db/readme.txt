This directory contains a tiny sql database to replace the previous iteminfos.ini files...
We do not want to need any sql server running in the background, so mysql may be too heavy for our choice. But a simple file-based sql database would be perfect here! --> sqlite !

To show the names of all existing tables, type 
  sqlite3 iteminfos.db ".tables"
on the command line in this folder. In order to list the contents of any table, write
  sqlite3 iteminfos.db  "SELECT * FROM rooms;"
or similar. To delete an item, type 
  sqlite3 iteminfos.db  "DELETE FROM items WHERE item_folder=\"item1\";"
and to delete all entries from the table "items", write
  sqlite3 iteminfos.db  "DELETE FROM items;"
WARNING: This actually will delete everything! So make a backup of iteminfos.db first!!

In order to print the complete contents of iteminfos.db to a text file (e.g. for migration to another database system), you can use the .dump command of sqlite3. You probably don't need this for backing up the inventory list, because you can instead simply copy the .db file. :-)

--Simon
