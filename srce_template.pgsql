UPDATE tps.SRCE

SET DEFN = 
$$
{
    "name": "WMPD",
    "descr": "Williams Paid File",
    "type":"csv",
    "schema": [
        {
            "key": "Carrier",
            "type": "text"
        },
        {
            "key": "SCAC",
            "type": "text"
        },
        {
            "key": "Mode",
            "type": "text"
        },
        {
            "key": "Pro #",
            "type": "text"
        },
        {
            "key": "B/L",
            "type": "text"
        },
        {
            "key": "Pd Amt",
            "type": "numeric"
        },
        {
            "key": "Loc#",
            "type": "text"
        },
        {
            "key": "Pcs",
            "type": "numeric"
        },
        {
            "key": "Wgt",
            "type": "numeric"
        },
        {
            "key": "Chk#",
            "type": "numeric"
        },
        {
            "key": "Pay Dt",
            "type": "date"
        },
        {
            "key": "Acct #",
            "type": "text"
        },
        {
            "key": "I/O",
            "type": "text"
        },
        {
            "key": "Sh Nm",
            "type": "text"
        },
        {
            "key": "Sh City",
            "type": "text"
        },
        {
            "key": "Sh St",
            "type": "text"
        },
        {
            "key": "Sh Zip",
            "type": "text"
        },
        {
            "key": "Cons Nm",
            "type": "text"
        },
        {
            "key": "D City ",
            "type": "text"
        },
        {
            "key": "D St",
            "type": "text"
        },
        {
            "key": "D Zip",
            "type": "text"
        },
        {
            "key": "Sh Dt",
            "type": "date"
        },
        {
            "key": "Inv Dt",
            "type": "date"
        },
        {
            "key": "Customs Entry#",
            "type": "text"
        },
        {
            "key": "Miles",
            "type": "numeric"
        },
        {
            "key": "Frt Class",
            "type": "text"
        },
        {
            "key": "Master B/L",
            "type": "text"
        }
    ],
    "unique_constraint": {
        "fields":[
            "{Pay Dt}",
            "{Carrier}" 
        ]
    }
}
$$::JSONB
WHERE
SRCE = 'WMPD'