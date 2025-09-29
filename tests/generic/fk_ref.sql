{% test fk_ref(model, fk_column, parent_model, pk_column) %}
select m.{{ fk_column }}
from {{ model }} m
left join {{ parent_model }} p on m.{{ fk_column }} = p.{{ pk_column }}
where p.{{ pk_column }} is null
{% endtest %}