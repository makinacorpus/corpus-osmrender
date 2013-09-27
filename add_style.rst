Add a style
===========
For desaturate, log of my operations:

* Edit .salt/PILLAR.sample and in data/styles, add:

.. code::

    desaturate:
        git_url: https://github.com/makinacorpus/osm-desaturate.git
        # git_rev: d789bdac60a17ff8fe18e6d8b978423147c21c53
        cfgs:
          /etc/tirex/renderer/mapnik/osm.conf: {}

* Copy the sample conf

.. code ::
    cp .salt/files/etc/tirex/renderer/mapnik/osm.conf .salt/files/etc/tirex/renderer/mapnik/desaturate.conf

* Adapt it

.. code::

    $EDITOR  .salt/files/etc/tirex/renderer/mapnik/desaturate.conf

* Edit & adapt ``.salt/400_osmstyle.sls``.


* Reconfigure

.. code::

    salt-call -lall mc_project.deploy osmrender only=install,fixperms

* Verify that ``../data/<style>style/project.xml`` variables are correctly generated

    * If not, reedit and fix 400_osmstyle & reinstall

* Wash, Rince, Repeat
