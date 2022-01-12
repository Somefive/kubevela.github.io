FROM nikolaik/python-nodejs:python3.10-nodejs17 as builder
WORKDIR /workspace
COPY ./ /workspace
RUN yarn install
RUN NODE_OPTIONS=--openssl-legacy-provider yarn build

FROM nginx:1.21
WORKDIR /
COPY --from=builder /workspace/build /usr/share/nginx/html
