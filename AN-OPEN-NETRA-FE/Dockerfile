# --- STAGE 1: Build ---
FROM node:16-alpine as build-stage
WORKDIR /app
COPY package*.json ./

RUN apk add --no-cache python3 make g++
RUN npm install --force

COPY . .
ENV DISABLE_ESLINT_PLUGIN=true
RUN npm run build

# --- STAGE 2: Production ---
FROM nginx:stable-alpine as production-stage

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=build-stage /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# FROM node:latest

# # Create app directory and set permissions
# RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app

# # Set working directory
# WORKDIR /home/node/app

# # Install npm globally if necessary npm version 8.5.1, uncomment the next line
# RUN npm install -g npm

# # Change to non-root user
# USER node

# # Copy package.json and package-lock.json
# COPY --chown=node:node package*.json ./

# # Copy the rest of the app
# COPY --chown=node:node . .

# # Set npm configuration
# RUN npm config set fetch-retry-mintimeout 20000
# RUN npm config set fetch-retry-maxtimeout 120000

# # Install project dependencies
# RUN npm install --force

# RUN npm install sass

# # Expose port
# EXPOSE 8080

# # Run the app
# CMD [ "npm", "run", "serve" ]

