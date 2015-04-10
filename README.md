# The Pusher HTTP REST API Reference

## Prerequisites

### Ruby

Ruby is required in order to install the [asciidoctor gem](https://rubygems.org/gems/asciidoctor)
and to build the protocol documentation.

## Editing the Docs

The docs are written in [AsciiDoc](http://asciidoctor.org/docs/what-is-asciidoc/)
and generated using [Asciidoctor](http://asciidoctor.org/).

To edit the docs simply edit the `README.adoc` using the AsciiDoc syntax.

## Building the Docs

The docs are built using a simple make command. The `MakeFile` first creates
images for the diagrams defined in `README.adoc` and then generates the HTML
document using [Asciidoctor](http://asciidoctor.org/).

From the working directory execute:

```
make
```

This will create a `rest_api.html` file which you can then open.
