# DeoJS - Javascript De-Obfuscator
## To Install:
```
npm install
```
Once installed, run using:
```
npm run dev
```


## VirusTotal Scanning
This currently needs a CORS proxy to connect to VirusTotal.

I've tested with [cors-anywhere](https://github.com/Rob--W/cors-anywhere). You'll need to change the port to 8000 as the webpack server uses port 8080.

You'll then need to add your VirusTotal API key at line 122 in `src/web/js/helpers/Input.worker.js`
