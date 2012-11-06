Sgoettschkes/openshift-php54
============================

This is a sample repository to get php 5.4 running on openshift. It's a 
work in progress!

More information about this project: tbd

More information about openshift: https://openshift.redhat.com/

What's inside
-------------

The misc/install.sh script installs:

* Apache 2.4.3
* PHP 5.4.7

It configures apache to have the diy folder as the document root. It also
uses the php.ini-development from the php archive and moves it into the 
correct folder.

The script does not remove the source files, so you can easily recompile 
Apache or PHP. Have a look at the shell script to see with which options
both were compiled the first time.

Usage
-----

To get PHP 5.4 working at OpenShift, you have to do the following:

1. Create a new Openshift "Do-It-Yourself" application
2. Clone this repository
3. Add a new remote "openshift" (You can find the URL to your git repository
   on the Openshift application page)
4. Run `git push --force "openshift" master:master`
5. SSH into your gear
6. `nohup ./repo/misc/install.sh > $OPENSHIFT_LOG_DIR/install.log`
7. Wait (This may take at least an hour)
8. Open http://appname-namespace.rhcloud.com/phpinfo.php to verify running 
   apache

Thanks
------

Thanks to the following people (ordered by name):

* [@marekjelen](https://github.com/marekjelen)
* [@venu](https://github.com/venu)

Todos
-----

This is stuff which needs to be done right now. Feel free to do a pull request!

* Add config description
* Add install docs
* Add description of what gets installed and how
* (Add link to blog with more in-depth explanation)