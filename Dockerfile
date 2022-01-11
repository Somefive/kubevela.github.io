FROM node:17-alpine as builder

WORKDIR /workspace
RUN yarn build

FROM nginx:1.21
WORKDIR /
COPY --from=builder /workspace/build /usr/share/nginx/html
