{#
 Override schema naming so custom schema is used as-is (no default prefix).
 This prevents dbt from creating DV_STAGING / DV_DV and instead uses STAGING / DV.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}
  {%- if custom_schema_name is not none and custom_schema_name|length > 0 -%}
    {{ return(custom_schema_name) }}
  {%- else -%}
    {{ return(target.schema) }}
  {%- endif -%}
{%- endmacro %}


