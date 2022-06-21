{% macro sandbox_models(models=[]) %}

    {% if not execute %} {# nodes are not available in compile stage #}
        {{ return(none) }}
    {%- endif -%}

    {% set all_model_names = [] %}
    {% set all_sources = [] %}

    {% for model_name in models %}

        {% set model = get_model_object(model_name) %}

        {% if model is none %}
            {{ log('Skipping ' ~ model_name ~ ': model does not exist', info=True) }}
        {% else %}
            {%  do all_model_names.append(model_name) %}

{#            Get all model dependencies  #}
            {% for ref in model.refs %}
                {% if ref is sequence and ref is not mapping and ref is not string %}
                    {%  do all_model_names.extend(ref) %}
                {% else %}
                    {%  do all_model_names.append(ref) %}
                {% endif %}
            {% endfor %}

{#            Get all source dependencies  #}
            {% for src in model.sources %}
                {% set source = get_source_object(src) %}
                {%  do all_sources.append(source) %}
            {% endfor %}

        {% endif %}

    {% endfor %}

    {% set all_models = [] %}

    {% for model_name in all_model_names %}
        {% set model = get_model_object(model_name) %}

        {% if model is none %}
            {{ log('Skipping ' ~ model_name ~ ': model does not exist', info=True) }}
        {% else %}
            {%  do all_models.append(model) %}
        {% endif %}
    {% endfor %}


    {% set processed_models = [] %}
    {% set processed_sources = [] %}

    {% for source in all_sources %}
        {% if source.name not in processed_sources %}
            {%  do processed_sources.append(source.name) %}

            {% if check_table_exists(source.name, '"'~source.database~'"."'~source.schema~'"') %}
                {% set query %}
                    CREATE OR REPLACE TABLE {{ target.database }}.{{ target.schema }}."{{ source.schema }}_{{ source.identifier }}"
                    CLONE {{ source.relation_name }};
                {% endset %}

                {{ log('Cloning source ' ~ source.relation_name ~ ' -> ' ~ target.database ~'.'~ target.schema ~'."'~ source.schema ~ '_'~ source.identifier~'"', info=True) }}
                {% do run_query(query) %}
            {% else %}
                {{ log('Skipping source ' ~ source.relation_name ~ '" - table not exists ', info=True) }}
            {% endif %}
        {% endif %}

    {% endfor %}

    {% for model in all_models %}
        {% if model.name not in processed_models %}
            {%  do processed_models.append(model.name) %}

            {% if model.config.schema is none %}
                {% set model_schema = var('main_schema') %}
            {% else %}
                {% set model_schema = var('main_schema')~'_'~model.config.schema %}
            {% endif %}

            {% if check_table_exists(model.name, model_schema) %}
                {% set query %}
                    CREATE OR REPLACE TABLE {{ target.database }}.{{ target.schema }}."{{ model.name }}"
                    CLONE {{ model_schema }}."{{ model.name }}";
                {% endset %}

                {{ log('Cloning model ' ~ model_schema ~'."' ~ model.name ~ '" -> ' ~ target.database ~'.'~ target.schema ~'."'~ model.name~'"', info=True) }}
                {% do run_query(query) %}
            {% else %}
                {{ log('Skipping model ' ~ model_schema ~'."' ~ model.name ~ '" - table not exists ', info=True) }}
            {% endif %}

        {% endif %}
    {% endfor %}
{% endmacro %}
