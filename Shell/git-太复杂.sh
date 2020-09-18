#!/bin/bash

# 声明支持的key值
mBranchTagKey="branchTag" # 分支或标签
# isRemoteBranchKey="isRemoteBranchKey" # 是否是远程分支

inputArguments=$*

# 提前处理一些参数
isRemote=
selectBranch=
remoteBranchPrefix=

# 没办法-_-!!!, shell中没有找到使用字典的方法，先这么着吧
getValue() {
  value=""
  for obj in $inputArguments
  do
    key=${obj%%=*}
    if [ -n $key ] && [ $key == $1 ]
    then
      value=${obj#*=}
      break
    fi
  done
  echo $value
}

getLocalBranch() {
  value=$(git branch --show-current)
  if [[ -z ${value} ]]; then
    value="HEAD"
  fi
  echo ${value}
}

getSelectBranch() {
  branch=$(git branch --remotes --list ${mBranchTag})

  if [[ -z ${branch} ]]; then
    branch=$(git branch --list ${mBranchTag})
    if [[ -n ${branch} ]]; then
      isRemote=false
    fi
  else
    isRemote=true
    remoteBranchPrefix=${branch#*/}
    selectBranch=${branch%%/*}
  fi
  echo ${branch}
}

mBranchTag=$(getValue ${mBranchTagKey})
# echo ${branchFull}
# if [[ ${branchFull} =~ origin/ ]]; then
#   #statements
#   echo "是远程分支"
# else
#   echo "不是"
# fi
# isRemote=$(${branchFull} =~ "origin/[\s]*")

# echo ${isRemote}

# for obj in $*
# do
#
#   value="${obj#*=}"
#   key="${obj%%=*}"
#   if [ -n $value ] && [ -n $key ]
#   then
#     inputArguments[$key]=$value
#   fi
# done

cd "/Users/apple/dev/TestProject/mytest"
# status=$(git status)
# # 判断当前是否存在未提交的
# if [[ "${status}" =~ "nothing to commit, working tree clean" ]]
# then
#   echo '没有更改'
# else
#   echo '更改'
#
#   git add *
#   commitMsg=$(getValue "commitMsg")
#   if [ -z ${commitMsg} ]
#   then
#     commitMsg="-"
#   fi
#   git commit -m ${commitMsg}
# fi

# currentBranch=$(git branch --show-current)
# if [ -z ${currentBranch} ]
# then
#   echo '当前在 HEAD 分支上'
# fi

# 判断当前传入

# 获取当前git存在的分支，即对应的远程分支
if [ -z ${mBranchTag} ]; then
  echo "没有指定分支/标签"
else

  echo $(getSelectBranch)
  echo "是否是远程分支：${isRemote}, 远程分支前缀：${remoteBranchPrefix}, 分支名： ${selectBranch}"
  # echo "${mBranchTag}"
  # branch=$(git branch --all --list ${mBranchTag})
  # if [[ -z ${branch} ]]; then
  #   echo "指定分支不存在"
  # else
  #   echo ${branch}
  # fi

  # tag=$(git ls-remote --refs --tags origin "*/${mBranchTag}" | awk -F '\t' '{print $2}' | awk -F '/' '{print $3}')
  #
  # if [[ -z ${tag} ]]; then
  #   echo "没有指定标签"
  # else
  #   echo ${tag}
  # fi
fi


# topGitLog=${gitLog $0}
# echo ${topGitLog}
