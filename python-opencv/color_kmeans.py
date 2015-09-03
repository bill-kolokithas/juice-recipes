# USAGE
# python color_kmeans.py --image images/jp.png --clusters 3

# import the necessary packages
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
import argparse
import utils
import cv2
from operator import itemgetter
from colormath.color_objects import sRGBColor, LabColor
from colormath.color_conversions import convert_color
from colormath.color_diff import delta_e_cmc

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-i", "--image", required = True, help = "Path to the image")
ap.add_argument("-c", "--clusters", required = True, type = int,
	help = "# of clusters")
args = vars(ap.parse_args())

# load the image and convert it from BGR to RGB so that
# we can display it with matplotlib
image = cv2.imread(args["image"])
image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

# crop dimensions
yPercent = 85.0
xPercent = 70.0
yEnd = image.shape[0] * (yPercent / 100)
yStart = image.shape[0] - yEnd
xEnd = image.shape[1] * (xPercent / 100)
xStart = image.shape[1] - xEnd

# crop image
image = image[yStart:yEnd, xStart:xEnd]

# show our image
plt.figure()
plt.axis("off")
plt.imshow(image)

# reshape the image to be a list of pixels
image = image.reshape((image.shape[0] * image.shape[1], 3))

# cluster the pixel intensities
clt = KMeans(n_clusters = args["clusters"])
clt.fit(image)

# build a histogram of clusters and then create a figure
# representing the number of pixels labeled to each color
hist = utils.centroid_histogram(clt)
bar = utils.plot_colors(hist, clt.cluster_centers_)

# set up values for known colors
colors = []
colors.append((convert_color(sRGBColor(94, 153, 25),  LabColor), "Green"))
colors.append((convert_color(sRGBColor(138, 50, 48),  LabColor), "Red"))
colors.append((convert_color(sRGBColor(233, 120, 54), LabColor), "Orange"))
colors.append((convert_color(sRGBColor(140, 65, 96),  LabColor), "Purple"))
colors.append((convert_color(sRGBColor(248, 215, 50), LabColor), "Yellow"))

# find dominant color
idx, _ = max(enumerate(hist), key=itemgetter(1))
color_rgb = sRGBColor(clt.cluster_centers_[idx][0], clt.cluster_centers_[idx][1], clt.cluster_centers_[idx][2])
color_lab = convert_color(color_rgb, LabColor)

# calculate the color difference from known colors
colordiffs = []
for color in colors:
    colordiffs.append(delta_e_cmc(color_lab, color[0]))

# print the known color we are the closest from
idx, _ = min(enumerate(colordiffs), key=itemgetter(1))
print colors[idx][1]

# show our color bart
plt.figure()
plt.axis("off")
plt.imshow(bar)
plt.show()
