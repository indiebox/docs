Roles section
=============

The roles section in an UBOS Manifest defines how the :term:`App` or :term:`Accessory`
needs to be deployed and related information. For example, the roles section defines:

* which files or directories need to be created in the file system;
* which databases need to be provisioned with which permissions;
* which directories or databases need to be backed up;
* which scripts to run after installation, before uninstallation, or for a version
  upgrade.

The roles section is structured by roles. Currently supported roles are:

* ``apache2``: information related to the web tier;
* ``tomcat8``: information related to the Java :term:`Apps <App>` running on Tomcat (if applicable);
* ``mysql``: information related to MySQL databases (if applicable);
* ``postgresql``: information related to Postgresql databases (if applicable);
* ``generic``: information not related to any of the other tiers (this is rare).

Generally, upon installation of an :term:`App` or :term:`Accessory`, the roles are processed in this sequence:

#. ``mysql`` or ``postgresql``
#. ``generic``
#. ``tomcat8``
#. ``apache2``

Upon uninstallation of an :term:`App` or :term:`Accessory`, the roles are processed in the opposite sequence.

Here are common fields for all roles:

Common fields
-------------

Depends
^^^^^^^

When the :term:`App` or :term:`Accessory` is deployed for this role, the field
``depends`` identifies required packages. Often, these dependencies could also be listed
in the package's :term:`PKGBUILD` file, but this additional field allows the declaration of
dependencies that are only required if this role is used.

Example:

.. code-block:: json

   "apache2" : {
     "depends" : [ "php-apache", "php-gd" ],
     ...

AppConfigItems
^^^^^^^^^^^^^^

This section captures the items that need to be put in place before a deployment of
an :term:`App` or :term:`Accessory` is functional. These items can be things such as files, directories,
symbolic links, or databases; but also scripts that need to be run.

For example, in the ``apache2`` role of an :term:`App` the following ``appconfigitems`` section
may be found:

.. code-block:: json

   "appconfigitems" : [
     {
       "type"         : "file",
       "name"         : "index.php",
       "source"       : "web/index.php",
     },
     {
       "type"         : "file",
       "name"         : "config.php",
       "template"     : "tmpl/config.php.tmpl",
       "templatelang" : "varsubst"
     },
     {
       "type"         : "symlink",
       "name"         : "gladiwashere.php",
       "source"       : "web/gladiwashere.php"
     }
   ]

Here, three items need to be put in place: two files, and a symbolic link. The following
:term:`AppConfigItem` types are currently supported:

* ``directory``: a directory to be created;
* ``directorytree`` : a recursive directory tree, copied from somewhere else;
* ``file``: a file, created by copying another file, or processing another file (see below);
* ``database``: a database that needs to be created (only use this for database roles such
  as the ``mysql`` role);
* ``perlscript``: a Perl script that needs to be run;
* ``sqlscript``: a SQL script that needs to be run (only use this for the ``mysql`` role);
* ``symlink``: a symbolic link;
* ``systemd-service``: a systemd service to be running while the :term:`AppConfiguration` is deployed;
* ``systemd-timer``: a systemd timer to be active while the :term:`AppConfiguration` is deployed;
* ``tcpport``: a TCP port needs to be reserved for the exclusive use of this :term:`AppConfiguration`;
* ``udpport``: a UDP port needs to be reserved for the exclusive use of this :term:`AppConfiguration`.

The field ``name`` is the name of the file, directory, database, systemd service or timer to
be created or operated on. ``names`` can be used as a shortcut for several
:term:`AppConfigItems <AppConfigItem>` to which the same other settings apply.

The field ``template`` identifies a file or directory that is to be used as a template for
creating the new item. The corresponding field ``templatelang`` states how the template
should be used to create the item. In the example above, the ``varsubst`` ("variable
substitution") algorithm is to be applied. (See :doc:`variables` and :doc:`scripts`.)

The field ``source`` refers to a file that is the source code for the script to be run,
or the destination of the symbolic link. (Think of the original file that is either being
copied, run, or pointed to with the symbolic link.)

The ``source`` field in case of ``directorytree``, ``file`` and ``symlink`` may contain:

* ``$1``: it will be replaced with the value of the ``name`` or current ``names`` entry.
* ``$2``: it will be replaced with the file name (without directories) of the ``name`` or
  current ``names`` entry.

The following table shows all attributes for :term:`AppConfigItems <AppConfigItem>` that
are defined:

+---------------------+----------------------------------------------+-------------------------------+-------------------------+
| JSON Entry          | Description                                  | Relative path context         | Mutually exclusive with |
+=====================+==============================================+===============================+=========================+
| ``charset``         | Default character set for SQL database       | N/A                           | N/A                     |
|                     | (default: Unicode)                           |                               |                         |
+---------------------+----------------------------------------------+-------------------------------+-------------------------+
| ``collate``         | Default collation set for SQL database       | N/A                           | N/A                     |
+---------------------+----------------------------------------------+-------------------------------+-------------------------+
| ``delimiter``       | SQL delimiter for sql scripts                | N/A                           | N/A                     |
|                     | (default: ``;``)                             |                               |                         |
+---------------------+----------------------------------------------+-------------------------------+-------------------------+
| ``dirpermissions``  | a string containing the octal number for the | N/A                           | N/A                     |
|                     | chmod permissions for directories in this    |                               |                         |
|                     | directory hierarchy (default: ``"0755"``)    |                               |                         |
+---------------------+----------------------------------------------+-------------------------------+-------------------------+
| ``filepermissions`` | a string containing the octal number for the | N/A                           | N/A                     |
|                     | chmod permissions for files in this          |                               |                         |
|                     | directory hierarchy (default: ``"0644"``)    |                               |                         |
+---------------------+----------------------------------------------+-------------------------------+-------------------------+
| ``gname``           | the name of the Linux group that this item   | N/A                           | N/A                     |
|                     | should belong to (default: ``root``).        |                               |                         |
+---------------------+----------------------------------------------+-------------------------------+-------------------------+
| ``name``            | the name of the created file, directory,     | ``${appconfig.apache2.dir}``  | ``names``               |
|                     | symlink, or root of the directory tree, or   |                               |                         |
|                     | the symbolic name of a database, or port     |                               |                         |
+---------------------+----------------------------------------------+-------------------------------+-------------------------+
| ``names``           | the names of the created files, directories, | ``${appconfig.apache2.dir}``  | ``name``                |
|                     | symlinks, or roots of the directory trees if |                               |                         |
|                     | more than one item supposed to be processed  |                               |                         |
|                     | with the same rule                           |                               |                         |
+---------------------+----------------------------------------------+-------------------------------+-------------------------+
| ``permissions``     | a string containing the octal number for the | N/A                           | N/A                     |
|                     | chmod permissions for this file or directory |                               |                         |
|                     | (default: ``"0644"`` for files, ``"0755"``   |                               |                         |
|                     | for directories)                             |                               |                         |
+---------------------+----------------------------------------------+-------------------------------+-------------------------+
| ``privileges``      | SQL privileges for the a database            | N/A                           | N/A                     |
+---------------------+----------------------------------------------+-------------------------------+-------------------------+
| ``retentionbucket`` | if given, captures that this item contains   | N/A                           | N/A                     |
|                     | valuable data that needs to be preserved,    |                               |                         |
|                     | e.g. when a backup is performed, and gives   |                               |                         |
|                     | it a symbolic name that becomes a named      |                               |                         |
|                     | section in backup files.                     |                               |                         |
+---------------------+----------------------------------------------+-------------------------------+-------------------------+
| ``retentionpolicy`` | the string ``"keep"``. All other values are  | N/A                           | N/A                     |
|                     | reserved.                                    |                               |                         |
+---------------------+----------------------------------------------+-------------------------------+-------------------------+
| ``source``          | the file to copy (or execute) without change | ``${package.codedir}``        | ``template``            |
+---------------------+----------------------------------------------+-------------------------------+-------------------------+
| ``template``        | a template file that will be copied after    | ``${package.codedir}``        | ``source``              |
|                     | being processed according to                 |                               |                         |
|                     | ``templatelang``                             |                               |                         |
+---------------------+----------------------------------------------+-------------------------------+-------------------------+
| ``templatelang``    | specifies the type of template processing to | N/A                           | ``source``              |
|                     | be performed if template is given            |                               |                         |
+---------------------+----------------------------------------------+-------------------------------+-------------------------+
| ``uname``           | the name of the Linux user account that      | N/A                           | N/A                     |
|                     | should own the created item (default:        |                               |                         |
|                     | ``root``)                                    |                               |                         |
+---------------------+----------------------------------------------+-------------------------------+-------------------------+

This table shows which attributes apply to which types of :term:`AppConfigItems <AppConfigItem>`:

+---------------------+--------------+----------+---------------+---------------+-----------+------------+------------+-------------+--------------+--------------+-------------+-------------+
| JSON Entry          | ``database`` | ``exec`` | ``directory`` | ``directory`` | ``file``  | ``perl``   | ``sql``    | ``symlink`` | ``systemd-`` | ``systemd-`` | ``tcpport`` | ``udpport`` |
|                     |              |          |               | ``tree``      |           | ``script`` | ``script`` |             | ``service``  | ``timer``    |             |             |
+=====================+==============+==========+===============+===============+===========+============+============+=============+==============+==============+=============+=============+
| ``delimiter``       |              |          |               |               |           |            | Y          |             |              |              |             |             |
+---------------------+--------------+----------+---------------+---------------+-----------+------------+------------+-------------+--------------+--------------+-------------+-------------+
| ``dirpermissions``  |              |          | Y             | Y             |           |            |            |             |              |              |             |             |
+---------------------+--------------+----------+---------------+---------------+-----------+------------+------------+-------------+--------------+--------------+-------------+-------------+
| ``filepermissions`` |              |          | Y             | Y             |           |            |            |             |              |              |             |             |
+---------------------+--------------+----------+---------------+---------------+-----------+------------+------------+-------------+--------------+--------------+-------------+-------------+
| ``gname``           |              |          | Y             | Y             | Y         |            |            | Y           |              |              |             |             |
+---------------------+--------------+----------+---------------+---------------+-----------+------------+------------+-------------+--------------+--------------+-------------+-------------+
| ``name``            | Y            |          | Y             | Y             | Y         |            | Y          | Y           | Y            | Y            | Y           | Y           |
+---------------------+--------------+----------+---------------+---------------+-----------+------------+------------+-------------+--------------+--------------+-------------+-------------+
| ``names``           |              |          | Y             | Y             | Y         |            |            | Y           |              |              |             |             |
+---------------------+--------------+----------+---------------+---------------+-----------+------------+------------+-------------+--------------+--------------+-------------+-------------+
| ``permissions``     |              |          |               |               | Y         |            |            |             |              |              |             |             |
+---------------------+--------------+----------+---------------+---------------+-----------+------------+------------+-------------+--------------+--------------+-------------+-------------+
| ``privileges``      | Y            |          |               |               |           |            |            |             |              |              |             |             |
+---------------------+--------------+----------+---------------+---------------+-----------+------------+------------+-------------+--------------+--------------+-------------+-------------+
| ``retentionbucket`` | Y            |          | Y             |               | Y         |            |            |             |              |              |             |             |
+---------------------+--------------+----------+---------------+---------------+-----------+------------+------------+-------------+--------------+--------------+-------------+-------------+
| ``retentionpolicy`` | Y            |          | Y             |               | Y         |            |            |             |              |              |             |             |
+---------------------+--------------+----------+---------------+---------------+-----------+------------+------------+-------------+--------------+--------------+-------------+-------------+
| ``source``          |              | Y        |               | Y             | Y         | Y          | Y          | Y           |              |              |             |             |
+---------------------+--------------+----------+---------------+---------------+-----------+------------+------------+-------------+--------------+--------------+-------------+-------------+
| ``template``        |              |          |               |               | Y         |            | Y          |             |              |              |             |             |
+---------------------+--------------+----------+---------------+---------------+-----------+------------+------------+-------------+--------------+--------------+-------------+-------------+
| ``templatelang``    |              |          |               |               | Y         |            | Y          |             |              |              |             |             |
+---------------------+--------------+----------+---------------+---------------+-----------+------------+------------+-------------+--------------+--------------+-------------+-------------+
| ``uname``           |              |          | Y             | Y             | Y         |            |            | Y           |              |              |             |             |
+---------------------+--------------+----------+---------------+---------------+-----------+------------+------------+-------------+--------------+--------------+-------------+-------------+


Installers, Uninstallers, Upgraders
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These fields identify scripts to be run when certain events occur:

* field ``installers`` is processed when the :term:`App` or :term:`Accessory` is deployed;
* field ``upgraders`` is processed after an :term:`App` or :term:`Accessory` has been deployed and
  data has been restored that potentially must be migrated to work with the current
  version of the :term:`App` or :term:`Accessory`.

Note that during software upgrades, deployment and undeployment may occur as well
(see :doc:`../understanding/update`).

Each of these fields points to an array. Each of the elements in the array is a separate
script that will be run in the sequence listed.

Here is an example for ``installers`` in the ``mysql`` role of an :term:`App` that uses MySQL:

.. code-block:: json

   "installers" : [
     {
       "name"   : "maindb",
       "type"   : "sqlscript",
       "source" : "mediawiki/maintenance/tables.sql"
     }
   ]

When this section is processed, UBOS will run the script ``mediawiki/maintenance/tables.sql``
of type ``sqlscript`` against the database whose symbolic name is ``maindb``.

Supported types are:

* ``sqlscript``: a SQL script (but only for the ``mysql`` role)
* ``perlscript``: a Perl script

Apache2 role
------------

The ``apache2`` role knows additional fields.

Context
^^^^^^^

Web :term:`Apps <App>` must specify one of the following two fields:

* ``defaultcontext``: the relative URL path at which the :term:`App` is installed by default.
  For example, Wordpress may have a defaultcontext of ``/blog``, i.e. if the user installs
  Wordpress at ``example.com``, by default Wordpress will be accessible at
  ``http://example.com/blog``. This field is to be used if the :term:`App` is able to be installed
  at any relative URL, but this is the default.
* ``fixedcontext``: some web :term:`Apps <App>` can only be installed at a particular relative URL,
  or only at the root of a :term:`Site`. Use ``fixedcontext`` to declare that relative URL.

Transport-level security (TLS) required
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Some :term:`Apps <App>` require that they be accessed via HTTPS only, using SSL/TLS, and will
refuse to work over HTTP. Such :term:`Apps <App>` need to declare this requirement, so
UBOS can prevent that they are deployed to an HTTP-only site. To declare this requirement,
use this JSON fragment:

.. code-block:: json

   "requirestls" : true

If not given, the default for this field is assumed to be ``false``.

Apache modules
^^^^^^^^^^^^^^

``apache2modules`` is a list of names of Apache2 modules that need to be activated before
the :term:`App` or :term:`Accessory` can be successfully run. Here is an example:

.. code-block:: json

   "apache2modules" : [
     "php7"
   ]

This declaration will make sure that the ``php7`` module is active in Apache2; if not yet,
UBOS will activate it and restart Apache2 without any further work by the :term:`App` or :term:`Accessory`.

Note that the ``apache2`` role still needs to declare a dependency on ``php7``;
``apache2modules`` does not attempt to infer which packages might be needed.

PHP modules
^^^^^^^^^^^

``phpmodules`` is a list of names of PHP modules that need to be activated before
the :term:`App` or :term:`Accessory` can be successfully run. Here is an example:

.. code-block:: json

   "phpmodules" : [
     "gd"
   ]

This declaration will make sure that the PHP module ``gd`` has been
activated; if not, UBOS will activate it and restart Apache2.

Note that the ``apache2`` role still needs to declare a dependency on ``php-gd``;
``apache2modules`` does not attempt to infer which packages might be needed.

Contributions to the site's "well-known"
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:term:`Sites <Site>` may publish certain "well-known" files, such as ``robots.txt`` or
the content of directory ``.well-known`` below the root of the :term:`Site`. Subject to
certain conflict resolution rules described in :doc:`<../site-json>`, an :term:`App` deployed
to a :term:`Site` may request to augment those entries.

For that purpose, the ``wellknown`` entry may be specified. Here is an example:

.. code-block:: json

   "wellknown" : {
     "carddav" : {
       "value" : "..."
     },
     "caldav" : {
       "location" : "caldav.php",
       "status" : "302 Found"
     },
     "webfinger" : {
       "proxy" : "http://localhost:1234/webfinger"
     }
   }

In ``wellknown``, each key-value pair represents an entry into the :term:`Site`'s
``/.well-known/`` context path, with the key being the name of the file and the value
being a JSON object with the following potential members. Note that ``robots.txt`` and
``webfinger`` follow different rules than all other entries:

``value``
   Static file content if there is; the value may be encoded. This field must not be
   used by ``robots.txt`` or ``webfinger``` entries (see additional fields below).

``encoding``
   If given, ``base64`` is the only valid value. It indicates that the value of
   ``value`` is provided using Base64 encoding and needs to be decoded first. This is
   useful for entries such as `favicon.ico`.

``location``
   Value for the HTTP redirect Location header when accessed. This is mutually exclusive with
   ``value``: only one of these two may be provided. This field must not be used by
   ``robots.txt`` or ``webfinger``` entries (see below). This value may use variables
   (as described in :doc:`variables`), which UBOS will replace during deployment.

``status``
   HTTP status code to return when accessed. This may only be specified when a
   ``location`` is provided, and the value must be a HTTP redirect status code,
   such as "307". When ``location`` is provided, the default is "307" (Temporary Redirect).

``allow``
   Only permitted for an entry whose key is ``robots.txt``. This field must have
   a value of type JSON array. The members of that array are individual ``Allow:`` entries
   for a composite ``robots.txt`` file. Each member is prefixed by the content path to
   the :term:`AppConfiguration` to which this :term:`App` has been deployed. For example,
   if one of the values is ``/assets/``, it will become ``Allow: /myapp/assets/`` if the
   :term:`App` has been deployed at context path ``/myapp``.`

``disallow``
   Just like ``allow``, but for ``Disallow:`` content for a composite ``robots.txt`` file.

``proxy``
   Only permitted for an entry whose key is ``webfinger``. This field must have a value of
   type string, containing a fully-qualified http or https URL. This specifies that UBOS,
   when a client requests the :term:`Site`'s well-known webfinger URL, should access the
   given URL, and semantically merge the resulting JSON files obtained from all :term:`App`s
   defining a well-known proxy at this :term:`Site`. This enables multiple :term:`App`s
   deployed to the :term:`Site` to all publish their contribution to the :term:`Site`'s
   webfinger well-known. This value may use variables (as described in :doc:`variables`),
   which UBOS will replace during deployment.


Phases
^^^^^^

When an :term:`AppConfiguration` with an :term:`App` and one ore more :term:`Accessories <Accessory>`
is deployed, generally the :term:`AppConfigItems <AppConfigItem>` of the :term:`App` are
deployed first, followed by the :term:`AppConfigItems <AppConfigItem>` of one
:term:`Accessory` at a time in the sequence the :term:`Accessories <Accessory>` were defined in the
:term:`Site JSON` file.

Then, any installer or upgrader scripts are run in the sequence they were defined in the
:term:`UBOS Manifest JSON`, with those defined by the :term:`App` before those defined by the
:term:`Accessories <Accessory>`.

Undeploying the :term:`AppConfiguration` occurs in the opposite sequence.

However, sometimes it is necessary to deviate from this default sequence, in particular if
the :term:`App` runs a daemon that requires that all :term:`Accessories <Accessory>` have been
deployed already at the time it starts.

For example, if an :term:`App` runs a Java daemon with :term:`Accessories <Accessory>` that
contribute optional JARs, and the daemon only scans the available JARs at the time it first
starts up, clearly the daemon can only start all :term:`Accessories <Accessory>` have been
deployed.

In order to support this (fairly rare) situation, the relevant
:term:`AppConfigItems <AppConfigItem>` (in the example, of type ``systemd-service`` that
starts the daemon) can be marked with an extra entry:

.. code-block:: json

   "phase" : "suspendresume"

This will cause the :term:`AppConfigItem` to be skipped on the first pass when installing
:term:`AppConfigItems <AppConfigItem>`, and only process it on a second pass that occurs
after the :term:`Accessories <Accessory>` have all been deployed.

No other values for ``phase`` are currently defined.

Status of the AppConfiguration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:term:`Apps <App>` may optionally declare an executable or script that, when invoked, reports
status information of the :term:`AppConfiguration` on which it is applied. This status information
is provided in JSON in a format defined in :doc:`../app-status`.

To declare such an executable or script, add the following JSON fragment in the ``apache2``
role in its :term:`App's <App>` UBOS Manifest JSON, assuming the Perl script ``status.pl``
in directory ``${appconfig.apache2.dir}`` should be invoked:

.. code-block:: json

   "status" : {
     "source" : "status.pl",
     "type"   : "perlscript"
   }

Alternatively, the ``exec`` type can be used:

.. code-block:: json

   "status" : {
     "source" : "status.sh",
     "type"   : "exec"
   }

The script or executable will be invoked with the same arguments as other scripts or
executables specified in the UBOS Manifest JSON, but the value for ``operation`` is
``status``.

This script or executable is only invoked while the :term:`App` has been deployed and
is supposed to be operational. It is not invoked at any other time.
