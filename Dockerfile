FROM nginx:1.21.1
LABEL maintainer = "Walid Majdoubi"

# Mettre à jour, installer les paquets nécessaires et supprimer les invites interactives
RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl git

# Supprimer les fichiers HTML par défaut
RUN rm -Rf /usr/share/nginx/html/*

# Cloner le repository dans le dossier de Nginx
RUN git clone https://github.com/diranetafen/static-website-example.git /usr/share/nginx/html

# Copier la configuration personnalisée de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Démarrer Nginx avec la variable PORT mise à jour
CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
