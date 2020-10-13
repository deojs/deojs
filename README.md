# DeoJS - Javascript De-Obfuscator
[![Build Status](https://travis-ci.com/deojs/deojs.svg?branch=master)](https://travis-ci.com/deojs/deojs)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
## Online version:
[Click here](https://deojs.github.io/) to access the online version of DeoJS.

This is up to date with the `master` branch, however doesn't support VirusTotal scanning.

## To Install:
```
npm install
```
Once installed, run using:
```
npm run dev
```
This will start the webpack dev server, which will be accessible at `http://localhost:8080/`


## VirusTotal Scanning
This currently needs a CORS proxy to connect to VirusTotal.

I've tested with [cors-anywhere](https://github.com/Rob--W/cors-anywhere). You'll need to change the port to 8000 as the webpack server uses port 8080.

You'll then need to add your VirusTotal API key at line 122 in `src/web/js/helpers/Input.worker.js`
