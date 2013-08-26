Add a style
===========

Of course, replace all occurences of ``desaturate`` by ``<yourstyle>``.


For desaturate, log of my operations:


* Edit .salt/PILLAR.sample and in data/styles, add:

    .. code::

        desaturate:
            git_url: https://github.com/makinacorpus/osm-desaturate.git
            # skip_mml: true/false (default true)
            #      Skipping would avoid to regenerate project.xml
            #      from project .mml if project.mml was found
            # git_rev: d789bdac60a17ff8fe18e6d8b978423147c21c53
            cfgs:
              /etc/tirex/renderer/mapnik/osm.conf: {}

* Copy the sample conf

    .. code ::

        cp .salt/files/etc/tirex/renderer/mapnik/osm.conf \
            .salt/files/etc/tirex/renderer/mapnik/desaturate.conf

* Adapt it

    .. code::

        $EDITOR  .salt/files/etc/tirex/renderer/mapnik/desaturate.conf

* Verify that you understand what ``.salt/400_osmstyle.sls`` will do,
  and maybe edit/adapt it for the new style.

* Reconfigure

    .. code::

        salt-call -lall mc_project.deploy osmrender only=install,fixperms

* If you need to get shapes, edit a ``<style_repo>/get-shapefiles.sh`` to grab
  them as the states will automatically call it.

* Verify that ``../data/<style>style/project.xml`` variables are correctly generated

    * If not, reedit and fix 400_osmstyle & reinstall

* Wash, Rince, Repeat

* When you are sure

    .. code::

        tirex-batch -p 21 z=5-12 map=desaturate bbox=-180,-90,180,90
