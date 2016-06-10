{%- import "makina-states/_macros/h.jinja" as h with context %}
{%- set cfg = opts.ms_project %}
{%- set data = cfg.data %}
{%- set dv=data.tirex_ver %}
{%- set packages = [
            'tirex-core',
            'tirex-backend-mapnik',
            'tirex-backend-mapserver',
            'tirex-backend-wms',
            'tirex-example-map',
            'tirex-nagios-plugin',]%}


{{cfg.name}}-git:
  git.latest:
    - name: https://github.com/geofabrik/tirex.git
    - target: {{cfg.data_root}}/tirex_build


{{cfg.name}}-build:
  cmd.run:
    - name: make && make deb
    - cwd: {{cfg.data_root}}/tirex_build
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
             |egrep '^{{i}}___'|grep -q {{data.tirex_ver}};\
             echo $?)
       if [ "x${v}" = "x0" ];then
          echo "changed=false";exit 0
       fi
       dpkg -i {{dpkg_arg}} {{cfg.data_root}}/{{fn}}
       echo changed=true
    - watch:
      - cmd: {{cfg.name}}-build
  {# exec a script because of this error
     dpkg-query: error: error writing to '<standard output>': Broken pipe #}
  cmd.run:
    - name: su -l -c {{sc}}
    - stateful: true
    - watch_in:
      - c_proxy: {{cfg.name}}-configs-post
    - watch:
      - file: {{prepkg}}
      - cmd: {{cfg.name}}-build
      {% if oprepkg %}- cmd: {{oprepkg}} {% endif %}
{% endfor %}

{{cfg.name}}-modtiledir-no-dir:
  file.absent:
    - name: /var/lib/mod_tile
    - unless: test -h /var/lib/mod_tile
{{cfg.name}}-modtiledir:
  file.symlink:
    - name: /var/lib/mod_tile
    - target: /var/lib/tirex/tiles
    - require:
      - file: {{cfg.name}}-modtiledir-no-dir

{{cfg.name}}-configs-pre:
  mc_proxy.hook:
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-post
{{cfg.name}}-configs-post:
  mc_proxy.hook: []

{% macro rmacro() %}
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-post
    - watch:
      - mc_proxy: {{cfg.name}}-configs-pre
{% endmacro %}
{{ h.deliver_config_files(
     data.get('tirex_cfgs', {}),
     dir='makina-projects/{0}/files'.format(cfg.name),
     mode='644',
     user=cfg.user, group=cfg.group,
     after_macro=rmacro,
     prefix=cfg.name+'-tyex-config-conf',
     project=cfg.name, cfg=cfg.name)}}

{{cfg.name}}-reload-tirex-master:
  service.running:
    - name: tirex-master
    - enable: true
    - watch:
      - mc_proxy: {{cfg.name}}-configs-post
{{cfg.name}}-reload-tirex-backend-manager:
  service.running:
    - name: tirex-backend-manager
    - enable: true
    - watch:
      - mc_proxy: {{cfg.name}}-configs-post
