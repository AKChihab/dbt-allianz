{% test fk_ref(model, parent_model, pk_column, column_name=None, fk_column=None) %}

{# prefer explicit fk_column, else use the column under test #}
{% set fk_col = fk_column or column_name %}

select m.{{ fk_col }} as fk_value
from {{ model }} as m
left join {{ parent_model }} as p
  on m.{{ fk_col }} = p.{{ pk_column }}
where m.{{ fk_col }} is not null         -- don’t fail on NULL FKs
  and p.{{ pk_column }} is null          -- orphaned FK

{% endtest %}
