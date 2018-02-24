
#encoding=utf8
'''
Detection with SSD
In this example, we will load a SSD model and use it to detect objects.
'''

import os
import sys
import argparse
import numpy as np
import pdb


from PIL import Image, ImageDraw, ImageFont
# Make sure that caffe is on the python path:
caffe_root = './'
os.chdir(caffe_root)
sys.path.insert(0, os.path.join(caffe_root, 'python'))
import caffe

from google.protobuf import text_format
from caffe.proto import caffe_pb2


def get_labelname(labelmap, labels):
    num_labels = len(labelmap.item)
    labelnames = []
    if type(labels) is not list:
        labels = [labels]
    for label in labels:
        found = False
        for i in xrange(0, num_labels):
            if label == labelmap.item[i].label:
                found = True
                labelnames.append(labelmap.item[i].display_name)
                break
        assert found == True
    return labelnames

class CaffeDetection:
    def __init__(self, gpu_id, model_def, model_weights, image_resize, labelmap_file):
        caffe.set_device(gpu_id)
        caffe.set_mode_gpu()

        self.image_resize = image_resize
        # Load the net in the test phase for inference, and configure input preprocessing.
        self.net = caffe.Net(model_def,      # defines the structure of the model
                             model_weights,  # contains the trained weights
                             caffe.TEST)     # use test mode (e.g., don't perform dropout)
         # input preprocessing: 'data' is the name of the input blob == net.inputs[0]
        self.transformer = caffe.io.Transformer({'data': self.net.blobs['data'].data.shape})
        self.transformer.set_transpose('data', (2, 0, 1))
        self.transformer.set_mean('data', np.array([104, 117, 123])) # mean pixel
        # the reference model operates on images in [0,255] range instead of [0,1]
        self.transformer.set_raw_scale('data', 255)
        # the reference model has channels in BGR order instead of RGB
        self.transformer.set_channel_swap('data', (2, 1, 0))

        # load PASCAL VOC labels
        file = open(labelmap_file, 'r')
        self.labelmap = caffe_pb2.LabelMap()
        text_format.Merge(str(file.read()), self.labelmap)

    def detect(self, image_file, conf_thresh=0.5, topn=5):
        '''
        SSD detection
        '''
        # set net to batch size of 1
        # image_resize = 300

	#pdb.set_trace()

        self.net.blobs['data'].reshape(1, 3, self.image_resize, self.image_resize)
        image = caffe.io.load_image(image_file)	

        #Run the net and examine the top_k results
        transformed_image = self.transformer.preprocess('data', image)
        self.net.blobs['data'].data[...] = transformed_image

        # Forward pass.
        detections = self.net.forward()['detection_out']

        # Parse the outputs.
        det_label = detections[0,0,:,1]
        det_conf = detections[0,0,:,2]
        det_xmin = detections[0,0,:,3]
        det_ymin = detections[0,0,:,4]
        det_xmax = detections[0,0,:,5]
        det_ymax = detections[0,0,:,6]

        # Get detections with confidence higher than 0.6.
        top_indices = [i for i, conf in enumerate(det_conf) if conf >= conf_thresh]

        top_conf = det_conf[top_indices]
        top_label_indices = det_label[top_indices].tolist()
        top_labels = get_labelname(self.labelmap, top_label_indices)
        top_xmin = det_xmin[top_indices]
        top_ymin = det_ymin[top_indices]
        top_xmax = det_xmax[top_indices]
        top_ymax = det_ymax[top_indices]

        result = []
        for i in xrange(min(topn, top_conf.shape[0])):
            xmin = top_xmin[i] # xmin = int(round(top_xmin[i] * image.shape[1]))
            ymin = top_ymin[i] # ymin = int(round(top_ymin[i] * image.shape[0]))
            xmax = top_xmax[i] # xmax = int(round(top_xmax[i] * image.shape[1]))
            ymax = top_ymax[i] # ymax = int(round(top_ymax[i] * image.shape[0]))
            score = top_conf[i]
            label = int(top_label_indices[i])
            label_name = top_labels[i]
            result.append([xmin, ymin, xmax, ymax, label, score, label_name])
        return result

def main(args):
    '''main '''
    detection = CaffeDetection(args.gpu_id,
                               args.model_def, args.model_weights,
                               args.image_resize, args.labelmap_file)
    
    #pdb.set_trace()

    imgpath = args.image_file
 
    savepath= '/Data/caffe/data/Volley/testImages/rawFrames_detections/'
    #savepath= '/Data/caffe/data/Volley/testImages/cropFrames_detections/'

    if not os.path.exists(savepath):
       os.makedirs(savepath)

    cnt = 0 
    for filename in os.listdir(imgpath):     
	   cnt += 1
	   imagename = filename
	   img2det = imgpath + imagename
	   print img2det

	   result = detection.detect(img2det)
    	   print result

	   img = Image.open(img2det)
	   draw = ImageDraw.Draw(img)
  	   dpfont = ImageFont.truetype("/Data/caffe/Fonts/Sans.ttf", 20)

  	   width, height = img.size
    	   #print width, height

	   tmpstr = ''
           if len(result)>0:
		   #pdb.set_trace()
     	  	   for item in result:
     		    	xmin = int(round(item[0] * width))
     		   	ymin = int(round(item[1] * height))
     		   	xmax = int(round(item[2] * width))
     		   	ymax = int(round(item[3] * height))
			xcenter = xmin+ (xmax - xmin)/2
			ycenter = ymin+ (ymax - ymin)/2 
     		   	draw.rectangle([xmin, ymin, xmax, ymax], outline=(255, 0, 0))
     		   	draw.text([xcenter, ycenter], item[-1] + str(round(item[-2],2)), (255, 0, 0), font = dpfont)
			act_label = str(item[-1])
			confidence = str(int(round(item[-2],2)*100))
			tmpstr = tmpstr + act_label + confidence+ 'percent'
     		   	print item
     		   	print [xmin, ymin, xmax, ymax]
     		   	print [xmin, ymin], item[-1]

	   outpath = savepath + imagename.split('.')[0]+'_'+tmpstr+'.jpg'
    	   img.save(outpath, 'JPEG')

def parse_args():
    '''parse args'''
    parser = argparse.ArgumentParser()
    parser.add_argument('--gpu_id', type=int, default=0, help='gpu id')
    parser.add_argument('--labelmap_file',
                        default='/Data/caffe/data/Volley/labelmap_volley.prototxt')
    parser.add_argument('--model_def',
                        default='/Data/caffe/models/Volley/1073img-model/SSD_300x300/deploy.prototxt')
    parser.add_argument('--image_resize', default=300, type=int)
    parser.add_argument('--model_weights',
                        default='/Data/caffe/models/Volley/1073img-model/SSD_300x300/'
                        'VGG_Volley_SSD_300x300_iter_60000.caffemodel')
    parser.add_argument('--image_file', default='/Data/caffe/data/Volley/testImages/rawFrames/')
    #parser.add_argument('--image_file', default='/Data/caffe/data/Volley/testImages/cropFrames/')

    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())
