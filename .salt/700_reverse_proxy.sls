{% set cfg = opts.ms_project %}
{% import "makina-states/services/http/apache/init.sls" as apache with context %}
include:
  - makina-states.services.http.apache
  - makina-states.services.http.apache_modfastcgi
{{apache.virtualhost(cfg.data.domain,
                     cfg=cfg.name,
                     **cfg.data.apache_vhost)}}


itworks:
  file.managed:
    - contents: '<html><body>itworks</body></html>'
    - name: "{{cfg.data.doc_root}}/index.html"
    - mode: 644
    - user: {{cfg.user}}
    - group: {{cfg.group}}
