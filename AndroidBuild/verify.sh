# 验证/判断

ismac() {
	if [[ "$(uname)" == "Darwin" ]]; then
		echo true
	else
		echo false
	fi
}
# 不是 mac 的都给认为 linux
islinux() {
	# if [[ "${systemType}" == "Linux" ]]; then
	if [[ "$(uname)" != "Darwin" ]]; then
		echo true
	else
		echo false
	fi
}