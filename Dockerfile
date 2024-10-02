# Base image
FROM node:14

# Set the working directory 
WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy all the application files
COPY . .

# Expose the API port
EXPOSE 3000

# Start the Node.js API
CMD ["npm", "start"]
