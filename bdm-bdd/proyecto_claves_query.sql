SELECT  1 AS CANTIDAD,
d2.etiqueta,
d1.fecha_cargue AS FECHA, 
d1.ubicacion AS UBICACION, 
d1.titulo AS TITULO, 
d1.contenido AS CONTENIDO, 
d1.link AS LINK, 
COALESCE (d3.nombre,'') AS FUENTE,
CASE CONCAT (positivo,negativo,neutro) 
		WHEN 'SNN' THEN 'POSITIVO'
		WHEN 'NSN' THEN 'NEGATIVO'
        WHEN 'NNS' THEN 'NEUTRO'
        ELSE 'NA'
 END AS SENTIMIENTO,
COALESCE (d4.nombre,'') AS DIRECTORIO

INTO OUTFILE '/var/lib/mysql-files/output.csv'
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
-- FIELDS ESCAPED BY '\'
LINES TERMINATED BY '\n' 

FROM cloud_bdm.ic_rss_coincidencias d1

LEFT JOIN ic_etiquetas d2
		ON d2.id = d1.id_etiqueta
LEFT JOIN ic_rss d3
		ON d3.id_rss = d1.id_rss

LEFT JOIN (
			ic_directorios d4 LEFT JOIN ic_concidencia_directorio d5 ON d5.id_directorio = d4.id
            ) ON d5.id_coincidencia = d1.id


WHERE id_etiqueta IN (SELECT id FROM cloud_bdm.ic_etiquetas
						WHERE usuario_cliente=834)

