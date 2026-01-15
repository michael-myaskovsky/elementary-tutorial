{{ config(materialized='table') }}

-- Your SQL query here


-- Add subscriber metadata
{{ config(
    meta={
        'subscribers': ['michael']
    }
) }}