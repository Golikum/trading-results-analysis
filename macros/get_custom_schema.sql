{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name == 'trading_marts' -%}
        trading_marts
    {%- else -%}
        {{ target.schema }}
    {%- endif -%}
{%- endmacro %}
