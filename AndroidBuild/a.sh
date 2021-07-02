source analyze.sh $*

echo $(valueAt a)
setSeparate :
echo $(valueAt b)

source verify.sh
echo $(ismac)
echo $(islinux)
