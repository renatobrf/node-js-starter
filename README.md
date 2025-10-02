# req.
- npm init -y
- npm install express ejs body-parser

# run
- node app.js

# build docker img
- docker build -t node-js-starter .

# run docker img
- docker run -p 3000:3000 node-js-starter
