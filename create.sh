#!/bin/bash

generateParamsTxt() {
  declare desc="parses the error message of create-stack, and lists missing params"

    error=$(aws cloudformation \
      create-stack --stack-name willfailforsure \
      --template-url ${templateUrl:=https://aws-quickstart.s3.amazonaws.com/quickstart-drupal/templates/drupal-master.template} \
      2>&1
    )
    e2=${error#*[}
    e3=${e2%]*}
    for e in ${e3//,/}; do 
      echo $e
    done
}

generateProfile() {
  while read p; do
    echo "export $p="; 
  done < params.txt
}

generateParams() {
  declare desc="generates the list for create-stack --parameters"

  while read p; do
    #echo "'ParameterKey=$p,ParameterValue=${!p}'" 
    echo "ParameterKey=$p,ParameterValue=${!p}" 
  done < params.txt
}

generateParamsJson() {
  declare desc="generates the json format for create-stack --parameters"
  echo '['
  prefix=""
  while read p; do
    # if param value contains "," use it as a list
    #if [[ "${!p}" == "${!p/,/}" ]];then 
    #  val='"'${!p}'"'
    #else 
    #  val="${!p}"
    #fi
    echo ${prefix}'{"ParameterKey": "'$p'", "ParameterValue": "'${!p}'"}'
    prefix="," 
  done < params.txt
  echo ']'
}
createStack() {
    echo "---> creating ${stackName:=drupal}"
    echo "---> templateUrl ${templateUrl:=https://aws-quickstart.s3.amazonaws.com/quickstart-drupal/templates/drupal-master.template}"

    echo aws cloudformation create-stack \
       --stack-name ${stackName} \
       --template-url ${templateUrl} \
       --parameters "$(generateParamsJson)" \
       --capabilities CAPABILITY_IAM
}


main() {
    if ! [[ -f params.txt ]] ; then
        generateParamsTxt > params.txt
        generateProfile > .profile
        echo "please fill out .profile"
    else 
      createStack "$@" 
    fi
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
