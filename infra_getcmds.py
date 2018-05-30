#!/usr/bin/env python
import sys
import yaml
import jinja2

vars_from_yaml = "virt_infra/infra_vars.yml"
template_file = "virt_infra/infra_templ.j2"


def render_one(vm):
	tplLoader = jinja2.FileSystemLoader(searchpath="./")
	tplEnv = jinja2.Environment(loader=tplLoader)
	template = tplEnv.get_template(template_file)
	outputText = template.render(vm=vm)
	return outputText

def render_template(req_name, all_servers):
	for host in all_servers:
		print(host['name'])
		if host['name'] == req_name:
			vm = host
			return render_one(vm)
	pass
	return ("Not found")


if __name__ == "__main__":
	infra_servers = yaml.load(open(vars_from_yaml, 'r'))
	print(infra_servers['infra_servers'])
	print(render_template('controller-1', infra_servers['infra_servers']))
	pass

