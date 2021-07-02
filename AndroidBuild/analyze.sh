# 解析

__inputParams_analyze_private=$*
__mark_analyze="="
setParams() {
	__params_analyze=$*
}
setSeparate() {
	if [[ -n $1 ]]; then
		__mark_analyze=$1
	fi
}
# 解析调去脚本传入的参数 key=value 这种类型的数据
# $1 表示 key
# $2 表示 当 key 没有值时的默认值
valueAt() {
	_value_analyze=""
	for _obj_analyze in $__inputParams_analyze_private
	do
		_key_analyze=${_obj_analyze%%"${__mark_analyze}"*}
		if [ -n "${_key_analyze}" ] && [ "${_key_analyze}" == $1 ]
		then
			_value_analyze=${_obj_analyze#*"${__mark_analyze}"}
	  		break
		fi
	done
	if [[ -n "${_value_analyze}" ]]; then
	  echo "${_value_analyze}"
 	else
	  echo $2
  	fi
}