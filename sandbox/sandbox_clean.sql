{% macro sandbox_clean() %}

    {% if not execute %} {# nodes are not available in compile stage #}
        {{ return(none) }}
    {%- endif -%}

    {% set schema = target.schema %}
    {% set allowed_schemas = var('sandbox_clean_allowed_schemas').split(',') %}

    {% if schema.lower() not in allowed_schemas %}
        {{ log('Clean works only for specific schemas: ' ~ allowed_schemas, true) }}
        {{ return(none) }}
    {%- endif -%}

    {% if target.name != 'dev' and target.name != 'test' %} {# nodes are not available in compile stage #}
        {{ log('Clean works only for dev target', true) }}
        {{ return(none) }}
    {%- endif -%}

    {% set tables = get_schema_tables(schema) %}

    {% if tables | length == 0 %}
        {{ log('Nothing to drop in schema ' ~ schema, true) }}
        {{ return(none) }}
    {%- endif -%}

    {% for t in tables %}
        {%- set query -%}
            DROP TABLE {{ schema }}."{{ t.name }}";
        {%- endset -%}
        {{ log(query, true) }}
        {% do run_query(query) %}

    {% endfor %}

{% endmacro %}
