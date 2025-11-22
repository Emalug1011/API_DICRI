# DICRI Backend - Proyecto base

Contenido del paquete:
- backend/ (código fuente)
- db/ (scripts SQL y stored procedures)
- Dockerfile, docker-compose.yml
- swagger.yaml
- tests/

## Imágenes (ERD / Flujo)
ERD (generado): /mnt/data/A_flowchart_in_Entity-Relationship_Diagram_(ERD)_s.png
Diagrama de flujo: /mnt/data/A_flowchart_in_the_form_of_a_digital_vector_graphi.png

## Levantar el entorno
1. Copiar .env con las variables (ejemplo en db/.env.example)
2. `docker compose up --build`
3. Backend disponible en http://localhost:3000

## Nota
Los stored procedures y scripts SQL están en `db/sps/` y el script de creación de BD en `db/create_database.sql`.
