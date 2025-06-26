-- marketing_ads model
SELECT * FROM {{ source('ads', 'stg_google_ads') }}
UNION ALL
SELECT * FROM {{ source('ads', 'stg_facebook_ads') }}
UNION ALL
SELECT * FROM {{ source('ads', 'stg_instagram_ads') }}