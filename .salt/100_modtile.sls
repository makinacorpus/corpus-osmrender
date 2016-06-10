{%- import "makina-states/_macros/h.jinja" as h with context %}
{%- set cfg = opts.ms_project %}
{%- set data = cfg.data %}
{%- set dv=data.modtile_ver %}
{%- set packages = [
      'renderd',
      'libapache2-mod-tile',
]%}

{{cfg.name}}-git:
  git.latest:
    - name: https://github.com/openstreetmap/mod_tile/
    - target: {{cfg.data_root}}/modtile_build

{{cfg.name}}-build:
  cmd.run:
    - name: |
            set -ex
            # ./autogen.sh
            # ./configure
            # make
            debuild -I -us -uc
    - cwd: {{cfg.data_root}}/modtile_build
    - use_vt: true
    - unless: |
        set -ex
        ver={{dv}}
        for i in {{' '.join(packages)}};do
          test -e ../${i}_${ver}*deb
        done
    - require:
      - git: {{cfg.name}}-git

{%- set prepkg = '' %}
{%- for i in packages %}
{%- set fn = '{0}_{1}*deb'.format(i, dv) %}
{%- set oprepkg = prepkg %}
{%- set prepkg = '{cfg[name]}-{i}-pkg'.format(cfg=cfg, i=i) %}
{%- set dpkg_arg='' %}
{%- set sc = '{0}/{1}.sh'.format(cfg.data_root, i) %}

{{prepkg}}:
  file.managed:
    - name: {{sc}}
    - mode: 750
    - contents: |
       #!/usr/bin/env bash
       set -ex
       v=$(dpkg -l|egrep ^ii|awk '{print $2 "___" $3}'\
             |egrep '^{{i}}___'|grep -q {{data.modtile_ver}};\
             echo $?)
       if [ "x${v}" = "x0" ];then
          echo "changed=false";exit 0
       fi
       export DEBIAN_FRONTEND=noninteractive
       dpkg -i {{dpkg_arg}} {{cfg.data_root}}/{{fn}}
       echo changed=true
    - watch:
      - cmd: {{cfg.name}}-build
  {# exec a script because of this error
     dpkg-query: error: error writing to '<standard output>': Broken pipe #}
  cmd.run:
    - name: su -l -c {{sc}}
    - stateful: true
    - require_in:
        - cmd: {{cfg.name}}-activate-modtile
    - watch:
      - file: {{prepkg}}
      - cmd: {{cfg.name}}-build
      {% if oprepkg %}- cmd: {{oprepkg}} {% endif %}
{% endfor %}

{{cfg.name}}-activate-modtile:
  cmd.run:
    - name: a2enmod tile && service apache2 restart
    - unless: test -e /etc/apache2/mods-enabled/tile.load

