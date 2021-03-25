import numpy as np
import keras
from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten, BatchNormalization
from keras.layers import Conv2D, MaxPooling2D,AveragePooling2D
from sklearn.model_selection import train_test_split
from keras import backend as K
import matplotlib.pyplot as plt
# K.set_session(sess)

np.random.seed(2010000)
Activity=8
Batch_Size=50
epochs=100
Chunk_size=60       #time_frame=1.2
n_input=28
input_shape = (7,60,2)

TrainTestSetes1=np.loadtxt('TD_DC.txt',delimiter=',')


Whole_Image_Data_train, Whole_Image_Data_test = train_test_split(TrainTestSetes1, test_size=2000)

y_train = Whole_Image_Data_train[:,840:]
y_test = Whole_Image_Data_test [:,840:]
x_train = Whole_Image_Data_train[:,:840].reshape(Whole_Image_Data_train[:,:840].shape[0], 7, 60,2)
x_test = Whole_Image_Data_test[:,:840].reshape(Whole_Image_Data_test[:,:840].shape[0], 7, 60,2)

model = Sequential()
model.add(Conv2D(20, kernel_size=(2,2),
                activation='relu',padding='same',
                input_shape=input_shape))
model.add(BatchNormalization())
model.add(AveragePooling2D(pool_size=(2, 4), strides=(2,4), padding='same', data_format=None))
model.add(Conv2D(40, kernel_size=(3,3),strides=(2, 1),padding='same',activation='relu'))
model.add(BatchNormalization())
model.add(AveragePooling2D(pool_size=(1,2), strides=(1,2), padding='same', data_format=None))

model.add(Flatten())
model.add(Dense(256, activation='relu'))
model.add(Dropout(0.3))
model.add(BatchNormalization())
model.add(Dense(Activity, activation='softmax'))

model.compile(loss=keras.losses.categorical_crossentropy,
              optimizer=keras.optimizers.Adam(lr=0.001),
              metrics=['accuracy'])

hist = model.fit(x_train, y_train,
          batch_size=Batch_Size,
          epochs=epochs,
          verbose=1,
          validation_data=(x_test, y_test))
score = model.evaluate(x_test, y_test, verbose=0)
model.save("MLModelKeras15_revised.h5")