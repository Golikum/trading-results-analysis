-- Macro to calculate net P&L consistently across models
-- Business rule: Net P&L = realized_pnl + commission
-- Note: Commission is typically negative (cost to client)

{% macro get_net_pnl(realized_pnl_column, commission_column) %}
    ({{ realized_pnl_column }} + {{ commission_column }})
{% endmacro %}
