{% macro concat_ws_snowflake(cols) -%}
  {%- for c in cols -%}
    COALESCE(CAST({{ c }} AS VARCHAR), '')
    {%- if not loop.last %} || '||' || {% endif -%}
  {%- endfor -%}
{%- endmacro %}

{% macro hashkey(cols) -%}
  HEX_ENCODE(SHA2({{ concat_ws_snowflake(cols) }}, 256))
{%- endmacro %}

{% macro hashdiff(cols) -%}
  {{ hashkey(cols) }}
{%- endmacro %}
