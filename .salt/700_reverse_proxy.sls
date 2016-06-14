{%- import "makina-states/_macros/h.jinja" as h with context %}
{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
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

{% for style, idata in data.styles.items() %}
{% set test_template  = idata.get('test_template', data.test_template) %}
{{ h.deliver_config_files({
        '/test.html': {'target': '{0}/{1}test.html'.format(data.doc_root, style)}
     },
     dir='makina-projects/{0}/files'.format(cfg.name),
     mode='644',
     user='www-data', group=cfg.group,
     prefix=cfg.name+style+'-test-conf',
     project=cfg.name, cfg=cfg.name, style=style)}}
{% endfor %}
