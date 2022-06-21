{% macro check_table_exists(table, schema) %}

    {% set query %}
        SHOW TABLES LIKE '{{ table }}' IN {{ schema }};
    {% endset %}

    {% set res = run_query(query) %}

{#    Tables with underscore characters can match multiple tables - check name is really equal#}
    {% for row in res %}
        {% if row.name == table %}
            {{ return(true) }}
        {% endif %}
    {% endfor %}

    {{ return(false) }}
{% endmacro %}
