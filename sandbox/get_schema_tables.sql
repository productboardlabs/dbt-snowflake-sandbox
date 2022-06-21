{% macro get_schema_tables(schema, database=none) %}

    {% set query %}
        {% if database is not none %}
            SHOW TERSE TABLES IN {{ database }}."{{ schema }}";
        {% else %}
            SHOW TERSE TABLES IN "{{ schema }}";
        {% endif %}
    {% endset %}

    {% set res = run_query(query) %}
    {{ return(res) }}
{% endmacro %}
