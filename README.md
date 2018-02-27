### From GPU Tesla V100 box

test submit 

### Function 1: Create list by group of action
always 86% for training, 14% for testing 

### Function 2: Detect frames given in two folders: raw or crop with magic proposal 
Use xingdongJiance to extract raw frames and crop frames first, then upload images to default folders for deteciton: 
```bash
/Data/caffe/data/Volley/testImages/rawFrames/
/Data/caffe/data/Volley/testImages/cropFrames/
```
change save path for detection results accordingly:
```bash
savepath= '/Data/caffe/data/Volley/testImages/rawFrames_detections/'
savepath= '/Data/caffe/data/Volley/testImages/cropFrames_detections/'
......
python detect_magic.py
```


