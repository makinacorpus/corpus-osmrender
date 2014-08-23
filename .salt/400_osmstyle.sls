{%- set cfg = opts.ms_project %}
{%- set data = cfg.data %}

{% for style, sdata in data.styles.items() %}
{{cfg.name}}-style-{{style}}-git:
  git.latest:
    - name: {{sdata.git_url}}
    - target: {{cfg.data_root}}/{{style}}style
    {% if sdata.get('git_rev', None)%}
    - rev: {{sdata.git_rev}}
    {% endif %}

{{cfg.name}}-style-{{style}}-build:
  cmd.run:
    - name: "carto project.mml > project.xml.in"
    - onlyif: test -e project.mml
    - cwd: {{cfg.data_root}}/{{style}}style
    - require:
      - git: {{cfg.name}}-style-{{style}}-git

{{cfg.name}}-style-{{style}}-gen:
  file.managed:
    - name: {{cfg.data_root}}/{{style}}-rewrite.sh
    - mode: 700
    - contents: |
        sed -r \
        -e 's|data/simplified-water-polygons-complete-3857/simplified_water_polygons.shp|data/water-polygons-split-3857/water_polygons.shp|g' \
        {% for i in ['host', 'port', 'password', 'user'] -%}
        -e 's|<Parameter name="{{i}}".*</Parameter>||g' \
        {% endfor -%}
        -e 's|(<Parameter name="dbname")|<Parameter name="host"><![CDATA[{{data.db_host}}]]></Parameter>  \1|g' \
        -e 's|(<Parameter name="dbname")|<Parameter name="host"><![CDATA[{{data.db_host}}]]></Parameter>  \1|g' \
        -e 's|(<Parameter name="dbname")|<Parameter name="user"><![CDATA[{{data.db_user}}]]></Parameter>  \1|g' \
        -e 's|(<Parameter name="dbname")|<Parameter name="port"><![CDATA[{{data.db_port}}]]></Parameter>  \1|g' \
        -e 's|(<Parameter name="dbname")|<Parameter name="password"><![CDATA[{{data.db_password}}]]></Parameter>   \1|g' \
        -e 's|(<Parameter name="dbname")><!\[CDATA\[[^\]+\]\]></Parameter>|<Parameter name="dbname"><![CDATA[{{data.db_name}}]]></Parameter>|g' \
        project.xml.in > project.xml
  cmd.run:
    - name: {{cfg.data_root}}/{{style}}-rewrite.sh
    - cwd: {{cfg.data_root}}/{{style}}style
    - require:
      - file: {{cfg.name}}-style-{{style}}-gen
      - cmd: {{cfg.name}}-style-{{style}}-build

{{cfg.name}}-style-{{style}}-shapes:
  cmd.run:
    - require:
      - cmd: {{cfg.name}}-style-{{style}}-build
    - name: ./get-shapefiles.sh
    - onlyif: test -e ./get-shapefiles.sh
    - use_vt: true
    - cwd: {{cfg.data_root}}/{{style}}style
    - unless: |
        set -ex
        {% if style in ['osm'] %}
        test -e ./data/world_boundaries-spherical.tgz
        test -e ./data/ne_110m_admin_0_boundary_lines_land.zip
        test -e ./data/ne_110m_admin_0_boundary_lines_land
        test -e ./data/ne_110m_admin_0_boundary_lines_land/ne_110m_admin_0_boundary_lines_land.shp
        test -e ./data/ne_110m_admin_0_boundary_lines_land/ne_110m_admin_0_boundary_lines_land.dbf
        test -e ./data/ne_110m_admin_0_boundary_lines_land/ne_110m_admin_0_boundary_lines_land.prj
        test -e ./data/ne_110m_admin_0_boundary_lines_land/ne_110m_admin_0_boundary_lines_land.index
        test -e ./data/ne_110m_admin_0_boundary_lines_land/ne_110m_admin_0_boundary_lines_land.shx
        test -e ./data/antarctica-icesheet-outlines-3857.zip
        test -e ./data/simplified-water-polygons-complete-3857
        test -e ./data/simplified-water-polygons-complete-3857/simplified_water_polygons.shx
        test -e ./data/simplified-water-polygons-complete-3857/simplified_water_polygons.cpg
        test -e ./data/simplified-water-polygons-complete-3857/simplified_water_polygons.dbf
        test -e ./data/simplified-water-polygons-complete-3857/simplified_water_polygons.shp
        test -e ./data/simplified-water-polygons-complete-3857/simplified_water_polygons.prj
        test -e ./data/simplified-water-polygons-complete-3857/simplified_water_polygons.index
        test -e ./data/antarctica-icesheet-polygons-3857.zip
        test -e ./data/water-polygons-split-3857.zip
        test -e ./data/antarctica-icesheet-polygons-3857
        test -e ./data/antarctica-icesheet-polygons-3857/icesheet_polygons.shp
        test -e ./data/antarctica-icesheet-polygons-3857/icesheet_polygons.prj
        test -e ./data/antarctica-icesheet-polygons-3857/icesheet_polygons.shx
        test -e ./data/antarctica-icesheet-polygons-3857/icesheet_polygons.index
        test -e ./data/antarctica-icesheet-polygons-3857/icesheet_polygons.dbf
        test -e ./data/water-polygons-split-3857
        test -e ./data/water-polygons-split-3857/water_polygons.index
        test -e ./data/water-polygons-split-3857/water_polygons.prj
        test -e ./data/water-polygons-split-3857/water_polygons.shx
        test -e ./data/water-polygons-split-3857/water_polygons.shp
        test -e ./data/water-polygons-split-3857/water_polygons.dbf
        test -e ./data/water-polygons-split-3857/water_polygons.cpg
        test -e ./data/world_boundaries
        test -e ./data/world_boundaries/builtup_area.dbf
        test -e ./data/world_boundaries/world_bnd_m.prj
        test -e ./data/world_boundaries/places.prj
        test -e ./data/world_boundaries/builtup_area.index
        test -e ./data/world_boundaries/builtup_area.shx
        test -e ./data/world_boundaries/world_bnd_m.shp
        test -e ./data/world_boundaries/places.shp
        test -e ./data/world_boundaries/world_boundaries_m.shx
        test -e ./data/world_boundaries/world_boundaries_m.index
        test -e ./data/world_boundaries/places.shx
        test -e ./data/world_boundaries/world_bnd_m.shx
        test -e ./data/world_boundaries/world_boundaries_m.dbf
        test -e ./data/world_boundaries/world_boundaries_m.shp
        test -e ./data/world_boundaries/builtup_area.shp
        test -e ./data/world_boundaries/world_bnd_m.dbf
        test -e ./data/world_boundaries/builtup_area.prj
        test -e ./data/world_boundaries/places.dbf
        test -e ./data/world_boundaries/world_bnd_m.index
        test -e ./data/world_boundaries/world_boundaries_m.prj
        test -e ./data/antarctica-icesheet-outlines-3857
        test -e ./data/antarctica-icesheet-outlines-3857/icesheet_outlines.index
        test -e ./data/antarctica-icesheet-outlines-3857/icesheet_outlines.shx
        test -e ./data/antarctica-icesheet-outlines-3857/icesheet_outlines.shp
        test -e ./data/antarctica-icesheet-outlines-3857/icesheet_outlines.dbf
        test -e ./data/antarctica-icesheet-outlines-3857/icesheet_outlines.prj
        test -e ./data/simplified-water-polygons-complete-3857.zip
        {% endif %}
{% endfor %}
