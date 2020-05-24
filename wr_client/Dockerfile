###############
# Build Stage #
###############
FROM alpine as build

RUN apk add yarn

COPY . .

RUN yarn install
RUN yarn build \
    && cp -rp public/ /export

####################
# Deployment Stage #
####################
FROM nginx

COPY --from=build /export /usr/share/nginx/html

EXPOSE 80
