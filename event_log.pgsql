SELECT 
    'MODULE',
    '2017-06-01'::DATE pdate,
    '2017-06-01'::DATE tdate,
    $${"attribute1":"value","attribute2":"value","attribute3":"value","attribute4":"value","attribute5":"value","attribute5":"value"}$$::jsonb,
    $${"account":"amount"}$$::jsonb ledger

