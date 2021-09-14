FROM node:alpine

# Install some depenendencies
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .

EXPOSE 8081
# Default command
CMD ["npm","start"] 