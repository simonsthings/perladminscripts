This folder contains an apache2 site configuration as is used e.g. in ubuntu. 
Copy it to /etc/apache2/sites-available/ or make a symbolic link.

Enable the site by typing "a2ensite inventory" and then "/etc/init.d/apache2 reload"

Don't forget to give apache (www-data in ubuntu) access to the perl scripts and the inventory base folder so that the items and thumbs folders can automatically be created!
