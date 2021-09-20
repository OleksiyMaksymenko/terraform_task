#!/bin/bash

text_for_msg=$(terraform plan)
WORDTOREMOVE="[0m"
text_for_msg=$(printf '%s\n' "${text_for_msg//$WORDTOREMOVE/}")
WORDTOREMOVE="[1m"
text_for_msg=$(printf '%s\n' "${text_for_msg//$WORDTOREMOVE/}")
WORDTOREMOVE="[32m"
text_for_msg=$(printf '%s\n' "${text_for_msg//$WORDTOREMOVE/}")

aws sns publish --topic-arn arn:aws:sns:eu-west-3:921302943194:proccesses_topic --message "$text_for_msg /n/n Terraform is ready to be build. Approve build manualy"
