# ---- Etapa base ----
    FROM node:18

    # Crear directorio de trabajo
    WORKDIR /app
    
    # Copiar package.json
    COPY package*.json ./
    
    # Instalar dependencias
    RUN npm install --production
    
    # Copiar todo el proyecto
    COPY . .
    
    # Exponer el puerto del backend
    EXPOSE 3001
    
    # Comando de inicio
    CMD ["node", "server.js"]
    