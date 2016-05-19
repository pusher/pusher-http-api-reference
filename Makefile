.PHONY: default
default: http_api.html pusher-http-api.json

http_api.html: http_api.adoc
	asciidoctor http_api.adoc

pusher-http-api.json: pusher-http-api.yaml
	ruby -ryaml -rjson -e "File.write('$@', JSON.pretty_generate(YAML.load_file('$<')))"
