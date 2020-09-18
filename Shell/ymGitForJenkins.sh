
# 支持的参数的key如下:
# commitMsg: 提交分支时的信息
# remoteBranch: 远程分支名
# addTag: 打标签
# addTagMsg: 打标签的附加信息

inputArguments=$*
# 对传入参数进行解析
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
# 获取本地分支
getLocalBranch() {
  localBranch=$(git branch --show-current)
  if [[ -z ${localBranch} ]]; then
    localBranch="HEAD"
  fi
  echo ${localBranch}
}
result=0

# 获取传入的远程分支内容
remoteBranch=$(git branch --remotes --list $(getValue "remoteBranch"))
if [[ -z ${remoteBranch} ]]; then
  echo "必须使用远程分支"
  exit 0
fi
branchName=${remoteBranch%%/*}

# 当前git是否需要提交
status=$(git status)
statusDidChange=true
# 判断当前是否存在未提交的
if [[ "${status}" =~ "nothing to commit, working tree clean" ]]
then
  statusDidChange=false
else
  echo "git 仓库被修改了"
  git add *
  commitMsg=$(getValue "commitMsg")
  if [ -z ${commitMsg} ]
  then
    commitMsg="-"
  fi
  git commit -m ${commitMsg}
fi
# 标签处理
addTag=$(getValue "addTag")
if [[ -n ${addTag} ]]; then
  isExist=$(git ls-remote --tags --refs ${addTag})
  if [[ ${isExist} =~ "does not appear to be a git repository" ]]; then
    # tag 已存在
    if [[ ${statusDidChange} == 'true' ]]; then
      echo '标签已存在'
      result=1
    fi
  else
    addTagMsg=$(getValue "addTagMsg")
    if [[ -z ${addTagMsg} ]]; then
      git tag -a ${addTag}
    else
      git tag -a ${addTag} -m ${addTagMsg}
    fi
    git push origin --tags
  fi
fi
# 提交远程
if [[ ${statusDidChange} == 'true' ]]; then
  git fetch --all
  currentBranch=$(localBranch)
  isNewForRemote=$(git log ${remoteBranch}..${currentBranch})
  if [[ -n ${isNewForRemote} ]]; then
    # 服务端也有新的提交，合并下
    mergeMsg=$(git merge ${remoteBranch})
    if [[ ${mergeMsg} =~ "Automatic merge failed; fix conflicts and then commit the result." ]]; then
      # 合并冲突
      echo "合并冲突"
      result=1
    fi
  fi
  if [[ ${result} != 1 ]]; then
    git push origin ${currentBranch}:${remoteBranch#*/}
  fi

fi

exit ${result}
