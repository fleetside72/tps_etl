SELECT
    *
FROM
    tps.srce_set(
        $$
            {
    "name": "PNCC",
    "type": "csv",
    "descr": "PNC Cash Accounts",
    "constraint": [
        "{AsOfDate}"
    ],
    "schemas": {
        "default": [
            {
                "path": "{AsOfDate}",
                "type": "date",
                "column_name": "AsOfDate"
            },
            {
                "path": "{BankId}",
                "type": "text",
                "column_name": "BankID"
            },
            {
                "path": "{AccountNumber}",
                "type": "text",
                "column_name": "AccountNumber"
            },
            {
                "path": "{AccountName}",
                "type": "text",
                "column_name": "AccountName"
            },
            {
                "path": "{BaiControl}",
                "type": "text",
                "column_name": "BaiControl"
            },
            {
                "path": "{Currency}",
                "type": "text",
                "column_name": "Currency"
            },
            {
                "path": "{Transaction}",
                "type": "text",
                "column_name": "Transaction"
            },
            {
                "path": "{Reference}",
                "type": "text",
                "column_name": "Reference"
            },
            {
                "path": "{Amount}",
                "type": "text",
                "column_name": "Amount"
            },
            {
                "path": "{Description}",
                "type": "text",
                "column_name": "Description"
            },
            {
                "path": "{AdditionalRemittance}",
                "type": "text",
                "column_name": "CurrencyAdditionalRemittance"
            }
        ]
    }
}
        $$::jsonb
    )