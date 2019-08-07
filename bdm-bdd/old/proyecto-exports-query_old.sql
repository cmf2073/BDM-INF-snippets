-- SET collation_connection = 'utf8_spanish_ci';
SELECT  1 AS CANTIDAD,
d2.etiqueta,
d1.fecha_cargue AS FECHA, 
-- d1.ubicacion AS UBICACION, 
-- TRIM('|' FROM d1.ubicacion) AS UBICACION,
IF (TRIM('|' FROM d1.ubicacion) = '','NA',TRIM('|' FROM d1.ubicacion)) AS UBICACION,
d1.titulo AS TITULO, 
-- TRIM(BOTH '\n' FROM d1.contenido) AS CONTENIDO, 
REPLACE (d1.contenido,'\n','') AS CONTENIDO,
d1.link AS LINK, 
-- COALESCE (d3.nombre,'') AS FUENTE,
CASE d1.id_rss 
     WHEN 432 THEN 'instagram'
     WHEN 433 THEN 'facebook'
     WHEN 434 THEN 'blogger'
     WHEN 435 THEN 'wordpress'
     WHEN 436 THEN 'tumblr'
     WHEN 437 THEN 'livejournal'
     WHEN 438 THEN 'twitter'
     WHEN 439 THEN 'youtube'
     ELSE 'NA' 
    END AS FUENTE,
CASE CONCAT (positivo,negativo,neutro) 
		WHEN 'SNN' THEN 'POSITIVO'
		WHEN 'NSN' THEN 'NEGATIVO'
        WHEN 'NNS' THEN 'NEUTRO'
        ELSE 'NA'
 END AS SENTIMIENTO,
COALESCE (d4.nombre,'') AS DIRECTORIO

-- INTO OUTFILE concat('/var/lib/mysql-files/output-', @client_ID ,'.csv');
INTO OUTFILE '/var/lib/mysql-files/OutFile2.csv'

FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
-- FIELDS ESCAPED BY '\'
escaped by ""
LINES TERMINATED BY '\r\n' 

FROM cloud_bdm.ic_rss_coincidencias d1

LEFT JOIN ic_etiquetas d2
		ON d2.id = d1.id_etiqueta
LEFT JOIN ic_rss d3
		ON d3.id_rss = d1.id_rss
LEFT JOIN (
			ic_directorios d4 LEFT JOIN ic_concidencia_directorio d5 ON d5.id_directorio = d4.id
            ) ON d5.id_coincidencia = d1.id
WHERE id_etiqueta IN (SELECT id FROM cloud_bdm.ic_etiquetas
						WHERE usuario_cliente=@clientID)
