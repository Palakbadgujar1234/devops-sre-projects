FROM registry.access.redhat.com/ubi8/nodejs-20-minimal:latest

USER root

RUN microdnf -y upgrade && microdnf clean all

WORKDIR /opt/app-root/src

COPY package.json app.js ./
COPY test ./test

RUN npm install --omit=dev

USER 1001

EXPOSE 8080

CMD ["npm", "start"]

# Made with Bob
