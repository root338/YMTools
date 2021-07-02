# git 相关的方法
# !!! 需要保证在目标目录中 !!!

# 设置远程分支
setremote() {
	__remote_url_git="$1"
}

is_commit_id() {
	if [[ "$1" =~ ^[0-9a-fA-F]{40}$ ]]; then
		echo true
	else
		echo false
	fi	
}
verify_commit_id() {
	if [[ ! $(is_commit_id $1) ]]; then
		echo $2
		exit 1
	fi
}

git_log() {
	echo git log --pretty="%H" -n $1
}

git_fetch() {
	if [[ -n $2 ]]; then
		git fetch "$__remote_url_git" "$1":"$2"
	else
		git fetch "$__remote_url_git" $1
	fi
}

git_checkout() {
	commitid=$(git ls-remote --tags --heads --refs "$__remote_url_git" $1 | cut -d -f 1)
	verify_commit_id "$commitid" "指定的参数($1)不存在节点，请检查输入"
	localcommitid=$(git_log)
	if [[ $(is_commit_id "$localcommitid") ]]; then
	else
		# localcommitid 一般认为本地没有提交
		git fetch "$"
	fi
}