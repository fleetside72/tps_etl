\timing
SELECT 
    r.*
    ,SUM(r."Amount") OVER (ORDER BY r."Post Date" asc , r."Description") + 1061.1 + 22.40 balance
FROM 
    tpsv.dcard_default r
ORDER BY 
    r."Post Date" asc