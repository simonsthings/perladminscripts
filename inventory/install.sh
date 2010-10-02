export STUFFROOT=/var/www/inventory

# make folders docroot, items, thumbs
mkdir $STUFFROOT/docroot
mkdir $STUFFROOT/items
mkdir $STUFFROOT/thumbs

# copy styles/index.html to docroot
cp $STUFFROOT/style/index.html $STUFFROOT/docroot

# create docroot/mainmenu.html and make webserver owner. (needs overwrite access)
echo "This is a placeholder. This file will be overwritten by main menu when you <a href='mainmenu.pl'>click here</a>." > $STUFFROOT/docroot/mainmenu.html

# copy itemreadme.txt to items folder as readme.txt
cp $STUFFROOT/style/itemfolderreadme.txt $STUFFROOT/items/readme.txt
# no chown here because we don't want anyone having write access to it.

# move iteminfos.db to something with a timestamp-old
mv $STUFFROOT/db/iteminfos.db $STUFFROOT/db/old$TS-iteminfos.db

# create fresh iteminfos.db out of schema.sql
echo Creating Database
sqlite3 $STUFFROOT/db/iteminfos.db < $STUFFROOT/db/schema.sql
echo Ok. Created.

# Give webserver ownership only to those files&folders it needs to write to:
chown www-data:www-data $STUFFROOT/docroot
chown www-data:www-data $STUFFROOT/items
chown www-data:www-data $STUFFROOT/thumbs
chown www-data:www-data $STUFFROOT/db/iteminfos.db
chown www-data:www-data $STUFFROOT/docroot/mainmenu.html

# make a symbolic link in apache directory to apacheconfig/inventory.
ln -s $STUFFROOT/apacheconf/inventory /etc/apache2/sites-enabled/inventory

# echo how to reload apache
echo "Now type '/etc/init.d/apache2 reload' !"