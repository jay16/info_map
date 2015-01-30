#!/bin/sh
git_comment="$1"


if [[ ! -n "${git_comment}" ]];
then
    echo "usage:"
    echo "./git_push.sh 本次提交的描述"
    echo ""
    echo "ps: 描述文字带空格请使用引号"
    exit 3
else
    git add -A .
    echo "git add $(test $? -eq 0 && echo "successfully" || echo "failed")."
    git commit -m "${git_comment}"
    echo "git commit $(test $? -eq 0 && echo "successfully" || echo "failed")."
    git push origin master
    echo "git push $(test $? -eq 0 && echo "successfully" || echo "failed")."
fi
