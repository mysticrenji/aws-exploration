FROM node:6.14.2-wheezy 

RUN mkdir /usr/src/goof
COPY . /usr/src/goof
WORKDIR /usr/src/goof

RUN npm update
RUN npm install
CMD ["npm", "start"]