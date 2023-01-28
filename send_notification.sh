#!/bin/bash
path=$1
# echo $path
text_for_msg=`cat $path`
# echo $text_for_msg
WORDTOREMOVE="[0m"
text_for_msg=$(printf '%s\n' "${text_for_msg//$WORDTOREMOVE/}")
WORDTOREMOVE="[1m"
text_for_msg=$(printf '%s\n' "${text_for_msg//$WORDTOREMOVE/}")
WORDTOREMOVE="[32m"
text_for_msg=$(printf '%s\n' "${text_for_msg//$WORDTOREMOVE/}")
WORDTOREMOVE="[33m"
text_for_msg=$(printf '%s\n' "${text_for_msg//$WORDTOREMOVE/}")
WORDTOREMOVE="[31m"
text_for_msg=$(printf '%s\n' "${text_for_msg//$WORDTOREMOVE/}")
WORDTOREMOVE="[90m"
text_for_msg=$(printf '%s\n' "${text_for_msg//$WORDTOREMOVE/}")
WORDTOREMOVE=""
text_for_msg=$(printf '%s\n' "${text_for_msg//$WORDTOREMOVE/}")
WORDTOREMOVE="─"
text_for_msg=$(printf '%s\n' "${text_for_msg//$WORDTOREMOVE/}")
# echo $text_for_msg
aws sns publish --topic-arn arn:aws:sns:us-east-1:596996137623:my-notif --message "$text_for_msg Terraform is ready to be built. Approve build manualy"
