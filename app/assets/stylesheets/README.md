This is my current bootstrap to start new projects with. It is, naturally, improved over time as I keep write CSS.

## Setup

 * Clone the repo to your project or add it as a submodule.
 * Setup the project by running `rake`.
 * Execute `sass --watch .:<css-dir>` (or `compass watch`) and start coding.
 * ... or have a look at `rake -T` while you are at it.

## Features

 * OOCSS-like structure: Core and Plugins.
 * Core and plugins are single partials. (`_<name>.scss`)
 * Two modes: dev or prod.

### OOCSS Plugins management

 * Create plugin (create bootstrap file and @import it to style.scss)
 * Destroy plugin (remove file and @import from style.scss)
 * Exclude plugin (remove @import from style.scss but keep file)
 * Include plugin (add @import to style.scss of an existing excluded file)

### CSSLint

 * Download latest rhino build from Github for linting files via CLI. [CSSLint CLI Docs](https://github.com/stubbornella/csslint/wiki/Command-line-interface)

### YUICompressor

 * Download latest JAR build from Yahoo!.
 * Compress files via CLI. [YUI Compressor docs](http://developer.yahoo.com/yui/compressor/#using)

### Other goodies worth mentioning

 * [Rake target to generate favicons and apple touch icons](https://gist.github.com/1423656)
 * [Image management in SCSS (base64, Sprites, dev-singles)](https://gist.github.com/2406978)