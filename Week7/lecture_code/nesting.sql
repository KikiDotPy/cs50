SELECT row 
FROM table 
WHERE id IN (SELECT row FROM table2 WHERE condition);
