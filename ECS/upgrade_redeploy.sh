#!/bin/bash

## make sure awscli is up-to-date
## pip install -U awscli

set -e

# generate new distributions
activator clean dist

# build Docker image
docker build -t renatbek/starpractice:play254 .
docker tag renatbek/starpractice:play254 445803720301.dkr.ecr.us-west-2.amazonaws.com/renatbek/starpractice:play254

# push to registry
eval "$(aws ecr get-login --region us-west-2)"
docker push 445803720301.dkr.ecr.us-west-2.amazonaws.com/renatbek/starpractice:play254


# register new task definition/revision
aws ecs register-task-definition --cli-input-json file:///Users/rbekbolatov/repos/gh/bekbolatov/numeric-base/ECS/starpractice_task_def_cli.json

# get latest revision number
export REVISION="$(aws ecs list-task-definitions --family-prefix StarPractice --sort DESC --max-items 1 | jq -r '.taskDefinitionArns[0]' | awk -F : '{ print $7 }')"

# set new task definition for the service
aws ecs update-service --cluster mini --service StarPractice --task-definition StarPractice:$REVISION
