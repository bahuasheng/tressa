#!/bin/bash

# Given ./asserts directory of .patch files (as created by get-asserts.sh),
# produces two files in ./asserts:
#   ./asserts/preds -> a compilation of all ASSERT statements lines in the
#   patch files (including + or -)
#   ./asserts/pred.sort -> same, but instead of multiple lines per duplicate,
#   simply duplicate counts. Additionally, sorted in some sense.

SRC=asserts
OUT=preds

cd ${SRC}

rm -f ${OUT}
rm -f ${OUT}.sorted

for patch in *
do
	echo ${patch}

	asserts=`grep '^+.* ASSERT(' ${patch}`
	if [ -n "${asserts}" ]
	then
		while read assert
		do
			pred_pos=`echo ${assert} | sed 's/^\+.*ASSERT(\(.*\)).*/\1/'`
			if [ -n "${pred_pos}" ]
			then
				echo "+ ${pred_pos}" >> ${OUT}
			fi
		done <<< "${asserts}"
	fi

	asserts=`grep '^-.* ASSERT(' ${patch}`
	if [ -n "${asserts}" ]
	then
		while read assert
		do
			pred_neg=`echo ${assert} | sed 's/[-].*ASSERT(\(.*\)).*/\1/'`
			if [ -n "${pred_neg}" ]
			then
				echo "- ${pred_neg}" >> ${OUT}
			fi
		done <<< "${asserts}"
	fi
done

cat ${OUT} | sort | uniq -c | sort > ${OUT}.sorted
