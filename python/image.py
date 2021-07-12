import numpy as np
import tensorflow as tf
import cv2
import matplotlib.pyplot as plt

interpreter = tf.lite.Interpreter(model_path="../assets/posenet_mv1_075_float_from_checkpoints.tflite")
interpreter.allocate_tensors()

# Get input and output tensors.
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

input_shape = input_details[0]['shape']
#print(input_shape)

def read_image(x):
    x = cv2.imread(x, cv2.IMREAD_COLOR)
    x = cv2.resize(x, (337,337))
    x = x.astype(np.float32)
    x = x/255
    x = np.expand_dims(x, axis=0)
    #x = (np.float32(x) - 127.5) / 127.5
    return x

input_data = read_image('./index.jpeg')
# print(input_data.shape)
# cv2.imshow("img",input_data)
# cv2.waitKey(10000)
# plt.imshow(img)
# plt.show()

interpreter.set_tensor(input_details[0]['index'], input_data)

interpreter.invoke()

# # The function `get_tensor()` returns a copy of the tensor data.
# # Use `tensor()` in order to get a pointer to the tensor.
output_data = interpreter.get_tensor(output_details[0]['index'])
offset_data = interpreter.get_tensor(output_details[1]['index'])
heatmaps = np.squeeze(output_data)
offsets = np.squeeze(offset_data)
#prob = np.array(output_data[0])
print(heatmaps.shape)
print(offsets.shape)

def parse_output(heatmap_data,offset_data, threshold):

  joint_num = heatmap_data.shape[-1]
  pose_kps = np.zeros((joint_num,3), np.uint32)

  for i in range(heatmap_data.shape[-1]):

      joint_heatmap = heatmap_data[...,i]
      max_val_pos = np.squeeze(np.argwhere(joint_heatmap==np.max(joint_heatmap)))
      remap_pos = np.array(max_val_pos/8*257,dtype=np.int32)
      pose_kps[i,0] = int(remap_pos[0] + offset_data[max_val_pos[0],max_val_pos[1],i])
      pose_kps[i,1] = int(remap_pos[1] + offset_data[max_val_pos[0],max_val_pos[1],i+joint_num])
      max_prob = np.max(joint_heatmap)

      if max_prob > threshold:
        if pose_kps[i,0] < 257 and pose_kps[i,1] < 257:
          pose_kps[i,2] = 1

  return pose_kps

# pose = parse_output(heatmaps, offsets, 0.1)
# print(pose)
# res = []
# for i in range(prob.shape[2]):
#     res.append(prob[:,:,i])
#     print(prob[:, :, i].shape)  # a view of original array. shape=(32, 32)
# print(len(res))

# test = res[0]
# print(test)

#print(prob.shape)
# cv2.imshow('OUT',test)
# cv2.waitKey(10000)

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

per = Person(heatmaps, offsets)
print(per.to_string())

print(len(per.keypoints))

list = []

for i in range(len(per.keypoints)):
    print(per.keypoints[i].x, per.keypoints[i].y, per.keypoints[i].body_part)
    map = {'body_part': per.keypoints[i].body_part, 'x': per.keypoints[i].x, 'y': per.keypoints[i].y, 'confidence': per.keypoints[i].confidence}
    list.append(map)

print(list)

# plt.imshow(prob, cmap='hot', interpolation='nearest')
# plt.show()