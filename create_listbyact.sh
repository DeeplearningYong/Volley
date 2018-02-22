# !/bin/bash

# suppose you have your dataset in ~/data/{datasetname}
# and all images in {Images}, all labels in {Labels}
# then you only need to change the dataset name
# and run create_list.sh just inside the dir
dataset="Volley"

data_root_dir=/Data/caffe/data/${dataset}/
current_dir=`pwd`
echo "current_dir: "${current_dir}
dst_all_tmp=${current_dir}"/all_tmp.txt"
dst_file_trainval=${current_dir}"/trainval.txt"
dst_file_test=${current_dir}"/test.txt"
dst_file_test_name_size=${current_dir}"/test_name_size.txt"

length_imgs=`ls -l ${data_root_dir}/Images|grep '^-'|wc -l`
length_labels=`ls -l ${data_root_dir}/Labels|grep '^-'|wc -l`
echo "all images count: "${length_imgs}
echo "all labels count: "${length_labels}

if [ ${length_imgs} != ${length_labels} ]; then
	echo "Images and Labels not equal count. Images and Labels must be same count!"
else
        j=0
	for img in `ls ${data_root_dir}/Images|sort -h`
	do
		img_list[${j}]=${img}
		((j++))
	done

	k=0
	for label in `ls ${data_root_dir}/Labels|sort -h`
	do
		label_list[${k}]=${label}
		((k++))
	done
	
	for ((i=0;i<${length_imgs};i++))
	do
		left=${img_list[i]}
		right=${label_list[i]}
		content="Images/"${left}" Labels/"${right}
		echo ${content} >> ${dst_all_tmp}		
	done
fi

# random shuffle the lines in all images
arr=(`seq ${length_imgs}`)
for ((i=0;i<${length_imgs};i++))
do
        let "a=$RANDOM%${length_imgs}"
        tmp=${arr[$a]}
        arr[$a]=${arr[$b]}
        arr[$b]=$tmp
done

# change this value to split trainval and test, default is 0.8
cnt_defense=0
cnt_handset=0
cnt_hit=0
cnt_hitblock=0
cnt_serve=0
cnt_set=0  

split_ratio=1
boundry=`echo | awk "{print int(${length_imgs}*${split_ratio})}"`
#echo "trainval count: "${boundry}
for i in ${arr[@]:0:${boundry}}
do
        labelfile=`sed -n "${i}p" ${dst_all_tmp}|cut -d ' ' -f 2`
        labelfilepath=${data_root_dir}${labelfile} 
        while IFS=' ' read -r f1 f2 f3 f4 f5
        do
            #printf 'action: %s, xmin: %s,  ymin: %s,  xmax: %s,  ymax: %s\n' "$f1" "$f2" "$f3" "$f4" "$f5"                                  
            if [[ $f1 == '0' ]]; then
                ((cnt_defense++))              
                echo 'defense counts:' $cnt_defense "action:" $f1 'filename:' $labelfilepath
                if [[ cnt_defense%7 -ne 0 ]]; then
                        echo 'train defense:'
                        sed -n "${i}p" ${dst_all_tmp} >> ${dst_file_trainval}
                else
                        echo 'test defense:'
                        line=`sed -n -e "${i}p" ${dst_all_tmp}|cut -d ' ' -f 1`
                        size=`identify ${data_root_dir}${line}|cut -d ' ' -f 3|sed -e "s/x/ /"`
                        name=`basename ${line} .png`                    
                        echo ${name}" "${size} >> ${dst_file_test_name_size}
                        sed -n "${i}p" ${dst_all_tmp} >> ${dst_file_test}
                fi
            fi
            if [[ $f1 == '1' ]]; then
                ((cnt_handset++))              
                echo 'handset counts:' $cnt_handset "action:" $f1 'filename:' $labelfilepath
                if [[ cnt_handset%7 -ne 0 ]]; then
                        echo 'train handset:'
                        sed -n "${i}p" ${dst_all_tmp} >> ${dst_file_trainval}
                else
                        echo 'test handset:'
                        line=`sed -n -e "${i}p" ${dst_all_tmp}|cut -d ' ' -f 1`
                        size=`identify ${data_root_dir}${line}|cut -d ' ' -f 3|sed -e "s/x/ /"`
                        name=`basename ${line} .png`                    
                        echo ${name}" "${size} >> ${dst_file_test_name_size}
                        sed -n "${i}p" ${dst_all_tmp} >> ${dst_file_test}
                fi
            fi

            if [[ $f1 == '3' ]]; then
                ((cnt_hitblock++))              
                echo 'hitblock counts:' $cnt_hitblock "action:" $f1 'filename:' $labelfilepath
                if [[ cnt_hitblock%7 -ne 0 ]]; then
                        echo 'train hitblock:'
                        sed -n "${i}p" ${dst_all_tmp} >> ${dst_file_trainval}
                else
                        echo 'test hitblock:'
                        line=`sed -n -e "${i}p" ${dst_all_tmp}|cut -d ' ' -f 1`
                        size=`identify ${data_root_dir}${line}|cut -d ' ' -f 3|sed -e "s/x/ /"`
                        name=`basename ${line} .png`                    
                        echo ${name}" "${size} >> ${dst_file_test_name_size}
                        sed -n "${i}p" ${dst_all_tmp} >> ${dst_file_test}
                fi
            fi

            if [[ $f1 == '4' ]]; then
                ((cnt_serve++))              
                echo 'serve counts:' $cnt_serve "action:" $f1 'filename:' $labelfilepath
                if [[ cnt_serve%7 -ne 0 ]]; then
                        echo 'train serve:'
                        sed -n "${i}p" ${dst_all_tmp} >> ${dst_file_trainval}
                else
                        echo 'test serve:'
                        line=`sed -n -e "${i}p" ${dst_all_tmp}|cut -d ' ' -f 1`
                        size=`identify ${data_root_dir}${line}|cut -d ' ' -f 3|sed -e "s/x/ /"`
                        name=`basename ${line} .png`                    
                        echo ${name}" "${size} >> ${dst_file_test_name_size}
                        sed -n "${i}p" ${dst_all_tmp} >> ${dst_file_test}
                fi
            fi
 
	    if [[ $f1 == '5' ]]; then
                ((cnt_set++))              
                echo 'set counts:' $cnt_set "action:" $f1 'filename:' $labelfilepath
                if [[ cnt_set%7 -ne 0 ]]; then
                        echo 'train set:'
                        sed -n "${i}p" ${dst_all_tmp} >> ${dst_file_trainval}
                else
                        echo 'test set:'
                        line=`sed -n -e "${i}p" ${dst_all_tmp}|cut -d ' ' -f 1`
                        size=`identify ${data_root_dir}${line}|cut -d ' ' -f 3|sed -e "s/x/ /"`
                        name=`basename ${line} .png`                    
                        echo ${name}" "${size} >> ${dst_file_test_name_size}
                        sed -n "${i}p" ${dst_all_tmp} >> ${dst_file_test}
                fi
            fi

            if [[ $f1 == '2' ]]; then
		((cnt_hit++))              
		echo 'hit counts:' $cnt_hit "action:" $f1 'filename:' $labelfilepath
		if [[ cnt_hit%7 -ne 0 ]]; then
                        echo 'train hit:'
                	sed -n "${i}p" ${dst_all_tmp} >> ${dst_file_trainval}
		else
 			echo 'test hit:'
			line=`sed -n -e "${i}p" ${dst_all_tmp}|cut -d ' ' -f 1`
			size=`identify ${data_root_dir}${line}|cut -d ' ' -f 3|sed -e "s/x/ /"`
			name=`basename ${line} .png`			
			echo ${name}" "${size} >> ${dst_file_test_name_size}
			sed -n "${i}p" ${dst_all_tmp} >> ${dst_file_test}
		fi
            fi
        done <"$labelfilepath"                
done


echo 'defense samples:' $cnt_defense
echo 'handset samples:' $cnt_handset
echo 'hit samples:' $cnt_hit
echo 'hitblock samples:' $cnt_hitblock
echo 'serve samples:' $cnt_serve
echo 'set samples:' $cnt_set  


# generate test.txt and test_name_size.txt
#for i in ${arr[@]:${boundry}:((${length_imgs}-${boundry}))}
#do
#	line=`sed -n -e "${i}p" ${dst_all_tmp}|cut -d ' ' -f 1`
#	size=`identify ${data_root_dir}${line}|cut -d ' ' -f 3|sed -e "s/x/ /"`
	#echo ${line}
#	name=`basename ${line} .png`
#	echo ${name}" "${size} >> ${dst_file_test_name_size}
#	sed -n "${i}p" ${dst_all_tmp} >> ${dst_file_test}
#done

# identify /Data/caffe/data/Volley/Images/000884.jpg get following output: 
# /Data/caffe/data/Volley/Images/000884.jpg JPEG 640x360 640x360+0+0 8-bit sRGB 66.5KB 0.000u 0:00.000
# ${arr[@]:${boundry}:((${length_imgs}-${boundry}))} => 884 1064 588 180 576 337 250 190 39 258 774 659 719 610 385 515 265 868 684 465 490 ......
# i => 884 
# line => Images/000884.jpg
# size => 640 360 
# name => 000884.jpg

# test.txt => Images/000884.jpg Labels/000884.txt
# trainval.txt => Images/000931.jpg Labels/000931.txt 
# test_name_size.txt => 000884.jpg 640 360 


rm -f ${dst_all_tmp}


echo "Done!"




