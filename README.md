# req.
- npm init -y
- npm install express ejs body-parser

# run
- node app.js

# build docker img
- docker build -t random-number-app .

# run docker img
- docker run -p 3000:3000 random-number-app
