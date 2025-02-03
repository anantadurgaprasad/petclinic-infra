profile=personal-aws

build-and-destroy:
	init
	plan
	apply
	sleep 60
	destroy-all

init:
	export AWS_DEFAULT_PROFILE=$(profile)
	terraform -chdir=infra init

plan: init
	terraform -chdir=infra plan

apply: init plan
	terraform -chdir=infra apply  --auto-approve

destroy-all:
	export AWS_DEFAULT_PROFILE=$(profile)
	terraform -chdir=infra destroy  --auto-approve
