# SUPER SIMPLE 'CLOUD NATIVE' WEB APP

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A super simple web app for demo purposes.

## Instructions

Full instructions with prometheus can be found [here](https://github.com/r3drun3/prometheus-demo)

build and run with docker:

```console
docker build -t test/app:latest . \
&& docker run -it --rm -p 8887:8887 test/app:latest
```

The web app UI can be visualized at `http://localhost:8887`:

<div>
  <p float="left">
    <img src="Images/webapp.png" width="1300" />
  </p>
</div>

<br/>

Note that the Flask Web app expose a `/metrics` endpoint:

<div>
  <p float="left">
    <img src="Images/metrics.png" width="1300" />
  </p>
</div>

this is the default endpoint that Prometheus will scrape.
<br>

