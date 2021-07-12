import numpy as np
import tensorflow as tf
import cv2
from firebase import firebase
import matplotlib.pyplot as plt
import json

firebase = firebase.FirebaseApplication("https://posenet-6a4c4-default-rtdb.firebaseio.com/", None)

data = {
    "Name": "PosenetApp",
    "type": "test"
}

res = firebase.post("/posenet-6a4c4-default-rtdb/Test", data)

print("start")

interpreter = tf.lite.Interpreter(model_path="../assets/posenet_mv1_075_float_from_checkpoints.tflite")
interpreter.allocate_tensors()

# Get input and output tensors.
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

input_shape = input_details[0]['shape']
#print(input_shape)

def read_image(x):
    #x = cv2.imread(x, cv2.IMREAD_COLOR)
    x = cv2.resize(x, (337,337))
    x = x.astype(np.float32)
    x = x/255
    x = np.expand_dims(x, axis=0)
    #x = (np.float32(x) - 127.5) / 127.5
    return x

PARTS = {
    0: 'NOSE',
    1: 'LEFT_EYE',
    2: 'RIGHT_EYE',
    3: 'LEFT_EAR',
    4: 'RIGHT_EAR',
    5: 'LEFT_SHOULDER',
    6: 'RIGHT_SHOULDER',
    7: 'LEFT_ELBOW',
    8: 'RIGHT_ELBOW',
    9: 'LEFT_WRIST',
    10: 'RIGHT_WRIST',
    11: 'LEFT_HIP',
    12: 'RIGHT_HIP',
    13: 'LEFT_KNEE',
    14: 'RIGHT_KNEE',
    15: 'LEFT_ANKLE',
    16: 'RIGHT_ANKLE'
}


def sigmoid(x):
    return 1 / (1 + np.exp(-x))


class Person():
    def __init__(self, heatmap, offsets):
        self.keypoints = self.get_keypoints(heatmap, offsets)
        self.pose = self.infer_pose(self.keypoints)

    def get_keypoints(self, heatmaps, offsets, output_stride=16):
        scores = sigmoid(heatmaps)
        num_keypoints = scores.shape[2]
        heatmap_positions = []
        offset_vectors = []
        confidences = []
        for ki in range(0, num_keypoints):
            x, y = np.unravel_index(
                np.argmax(scores[:, :, ki]), scores[:, :, ki].shape)
            confidences.append(scores[x, y, ki])
            offset_vector = (offsets[y, x, ki],
                             offsets[y, x, num_keypoints + ki])
            heatmap_positions.append((x, y))
            offset_vectors.append(offset_vector)
        image_positions = np.add(
            np.array(heatmap_positions) *
            output_stride,
            offset_vectors)
        keypoints = [KeyPoint(i, pos, confidences[i])
                     for i, pos in enumerate(image_positions)]
        return keypoints

    def infer_pose(self, coords):
        return "Unknown"

    def get_coords(self):
        return [kp.point() for kp in self.keypoints]  # if kp.confidence > 0.8

    def get_limbs(self):
        pairs = [
            (5, 6),
            (5, 7),
            (7, 9),
            (5, 11),
            (11, 13),
            (13, 15),
            (6, 8),
            (8, 10),
            (6, 12),
            (12, 14),
            (14, 16),
            (11, 12)
        ]
        # if (self.keypoints[i].confidence > 0.8 and
        # self.keypoints[j].confidence > 0.8)
        limbs = [(self.keypoints[i].point(), self.keypoints[j].point())
                 for i, j in pairs]
        return list(filter(lambda x: x is not None, limbs))

    def confidence(self):
        return np.mean([k.confidence for k in self.keypoints])

    def to_string(self):
        return "\n".join([a.to_string() for a in self.keypoints])


class KeyPoint():
    def __init__(self, index, pos, v):
        x, y = pos
        self.x = x
        self.y = y
        self.index = index
        self.body_part = PARTS.get(index)
        self.confidence = v

    def point(self):
        return int(self.y), int(self.x)

    def to_string(self):
        return 'part: {} location: {} confidence: {}'.format(
            self.body_part, (self.x, self.y), self.confidence)

def poseNet(img):
    input_data = read_image(img)
    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()
    output_data = interpreter.get_tensor(output_details[0]['index'])
    offset_data = interpreter.get_tensor(output_details[1]['index'])
    heatmaps = np.squeeze(output_data)
    offsets = np.squeeze(offset_data)
    per = Person(heatmaps, offsets)
    list = []
    print(per)
    for i in range(len(per.keypoints)):
        # print(per.keypoints[i].x, per.keypoints[i].y, per.keypoints[i].body_part)
        map = {'body_part': per.keypoints[i].body_part, 'x': per.keypoints[i].x, 'y': per.keypoints[i].y, 'confidence': per.keypoints[i].confidence}
        list.append(map)
    #print(list)
    return list

print("Video")
vid = cv2.VideoCapture('./Lambergini Video.mp4')
final = []

while True:
    ret, image = vid.read()
    if ret==True:
        res = poseNet(image)
        print(res)
        final.append(res)
        if len(final) == 200:
                    break
        print(len(final))
        cv2.waitKey(1)
        if cv2.waitKey(1) & 0xFF == ord('s'):
            		break

    else:
	        break
	
vid.release()

cv2.destroyAllWindows()

print("The video was successfully saved")

print(json.dumps(str(final)))

data = {
    "Lambergini" : json.dumps(str(final))
}
res = firebase.post("/posenet-6a4c4-default-rtdb/Lamborghini", data)
print(res)
