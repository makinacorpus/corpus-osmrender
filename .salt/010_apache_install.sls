{% set cfg = opts.ms_project %}
{% import "makina-states/services/http/apache/init.sls" as apache with context %}
include:
  - makina-states.services.http.apache
