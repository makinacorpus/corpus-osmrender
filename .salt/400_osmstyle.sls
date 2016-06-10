{%- set cfg = opts.ms_project %}
{%- set data = cfg.data %}

{{cfg.name}}-style-git:
  git.latest:
    - name: {{data.style_git}}
    - target: {{cfg.data_root}}/osmstyle

{{cfg.name}}-style-build:
  cmd.run:
    - name: "carto project.mml > project.xml"
    - unless: test -e project.xml
    - cwd: {{cfg.data_root}}/osmstyle
    - require:
      - git: {{cfg.name}}-style-git

{{cfg.name}}-style-shapes:
  cmd.run:
    - name: ./get-shapefiles.sh
    - use_vt: true
    - cwd: {{cfg.data_root}}/osmstyle
    - unless: |
        set -ex
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
    - require:
      - cmd: {{cfg.name}}-style-build