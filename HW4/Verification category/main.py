import cv2
import numpy as np

img = cv2.imread("./image.jpg")
img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
img = cv2.resize(img, (32, 31), interpolation=cv2.INTER_AREA)
img_del = np.delete(img, (1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29), axis=0)

img1 = img_del.flatten()
np.savetxt('img.dat', img1, fmt='%x', newline='\n')

n = 1
i = 0
j = 2
while n < 30:
    for k in range(0, 32):
        if k == 0 or k == 31:
            img[n, k] = (int(img[i, k]) + int(img[j, k]))/2
        else:
            n1 = abs(int(img[i, k-1]) - int(img[j, k+1]))
            n2 = abs(int(img[i, k]) - int(img[j, k]))
            n3 = abs(int(img[i, k+1]) - int(img[j, k-1]))
            smallest = min(n1, n2, n3)
            if smallest == n2:
                img[n, k] = (int(img[i, k]) + int(img[j, k]))/2
            elif smallest == n1:
                img[n, k] = (int(img[i, k-1]) + int(img[j, k+1]))/2
            else:
                img[n, k] = (int(img[i, k+1]) + int(img[j, k-1]))/2

    n += 2
    i += 2
    j += 2

img2 = img.flatten()
np.savetxt('golden.dat', img2, fmt='%x', newline='\n')
