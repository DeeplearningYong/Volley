### From GPU Tesla V100 box

### Function 1: Create list by group of action
always 86% for training, 14% for testing 

### Function 2: Detect with magic proposals with given folder of images
Use xingdongJiance to extract raw frames and crop frames first, then upload images to: 
```bash
/Data/caffe/data/Volley/testImages/rawFrames/
/Data/caffe/data/Volley/testImages/cropFrames/
```
change save path accordingly:
```bash
savepath= '/Data/caffe/data/Volley/testImages/rawFrames_detections/'
savepath= '/Data/caffe/data/Volley/testImages/cropFrames_detections/'
```


