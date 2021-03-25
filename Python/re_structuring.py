
##(7063, 1440) total data
import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal

#np.random.seed(2010000)
Activity=7
Batch_Size=50
Chunk_size=60       #time_frame=1.2

#################################################################################
Walking1=np.loadtxt('Walk_Tsige_one_res.txt',delimiter=',')
Walking2=np.loadtxt('Walking_Tsige_two_res.txt',delimiter=',')
Walking=np.concatenate((Walking1,Walking2))

Jumping1=np.loadtxt('Jump_Tsige_one_res.txt',delimiter=',')
Jumping2=np.loadtxt('Jumping_Tsige_two_res.txt',delimiter=',')
Jumping=np.concatenate((Jumping1,Jumping2))

Up_Stair1=np.loadtxt('Up_Stair_Tsige_one_res.txt',delimiter=',')
Up_Stair2=np.loadtxt('UpStair_Tsige_two_res.txt',delimiter=',')
Up_Stair=np.concatenate((Up_Stair1,Up_Stair2))

Down_Stair1=np.loadtxt('Down_Stair_Tsige_one_res.txt',delimiter=',')
Down_Stair2=np.loadtxt('DownStair_Tsige_two_res.txt',delimiter=',')
Down_Stair=np.concatenate((Down_Stair1,Down_Stair2))

Running=np.loadtxt('Running_Allen_one_res.txt',delimiter=',')
Bike_Riding=np.loadtxt('Jitensha_Allen_one_res.txt',delimiter=',')

Sitting1=np.loadtxt('Sitting_Tsige_one_res.txt',delimiter=',')
Sitting2=np.loadtxt('Sitting_Tsige_two_res.txt',delimiter=',')
Still=np.concatenate((Sitting1,Sitting2))
#################################################################################

def Signal_Arranger(Data1,Data2):
    Raw_size=Data1.shape[1]
    if Raw_size%(Chunk_size/2)==0:
        Counter=Raw_size//(Chunk_size//2)-1
    else:
        Counter=Raw_size//(Chunk_size//2)
    Data_Accum=np.zeros([1,30*Chunk_size])
    for i in range(Counter):
        if i==0:
            Boun_Low=0
            Boun_High=Chunk_size
            
        else:
            Boun_Low=i*(Chunk_size//2)
            Boun_High=Boun_Low+Chunk_size
        if Boun_High>Raw_size:
            
            Temp_Data1=Data1[:,Raw_size-Chunk_size:Raw_size]
            Temp_Data1_x = Temp_Data1[0].reshape(1,-1)
            
            Temp_Data2=Data2[:,Raw_size-Chunk_size:Raw_size]
            Temp_Data2_x = Temp_Data2[0].reshape(1,-1)
            
            Temp_Data_f1=np.abs(np.fft.fft(Temp_Data1,axis=1))
            Temp_Data_f1_x = Temp_Data_f1[0].reshape(1,-1)
            
            Temp_Data_f2=np.abs(np.fft.fft(Temp_Data2,axis=1))
            Temp_Data_f2_x = Temp_Data_f2[0].reshape(1,-1)
            
            Temp_Data1=Temp_Data1.reshape(1,-1)
            Temp_Data2=Temp_Data2.reshape(1,-1)
            Temp_Data_f1=Temp_Data_f1.reshape(1,-1)
            Temp_Data_f2=Temp_Data_f2.reshape(1,-1)


            Temp_Freq_Data=np.concatenate((Temp_Data1,Temp_Data1,Temp_Data1_x,
                                          Temp_Data2,Temp_Data2,Temp_Data2_x,
                                          Temp_Data_f1,Temp_Data_f1,Temp_Data_f1_x,
                                          Temp_Data_f2,Temp_Data_f2,Temp_Data_f2_x),axis=1)
            Data_Accum=np.concatenate((Data_Accum,Temp_Freq_Data))
        else:
            Temp_Data1=Data1[:,Boun_Low:Boun_High]
            Temp_Data1_x = Temp_Data1[0].reshape(1,-1)
          
            Temp_Data2=Data2[:,Boun_Low:Boun_High]
            Temp_Data2_x = Temp_Data2[0].reshape(1,-1)
            
            Temp_Data_f1=np.abs(np.fft.fft(Temp_Data1,axis=1))
            Temp_Data_f1_x = Temp_Data_f1[0].reshape(1,-1)
            
            Temp_Data_f2=np.abs(np.fft.fft(Temp_Data2,axis=1))
            Temp_Data_f2_x = Temp_Data_f2[0].reshape(1,-1)
            
            Temp_Data1=Temp_Data1.reshape(1,-1)
            Temp_Data2=Temp_Data2.reshape(1,-1)
            Temp_Data_f1=Temp_Data_f1.reshape(1,-1)
            Temp_Data_f2=Temp_Data_f2.reshape(1,-1)


            Temp_Freq_Data=np.concatenate((Temp_Data1,Temp_Data1,Temp_Data1_x,
                                          Temp_Data2,Temp_Data2,Temp_Data2_x,
                                          Temp_Data_f1,Temp_Data_f1,Temp_Data_f1_x,
                                          Temp_Data_f2,Temp_Data_f2,Temp_Data_f2_x),axis=1)
            Data_Accum=np.concatenate((Data_Accum,Temp_Freq_Data))
    return Data_Accum
#


################################################################################################

def One_Hot_Vect(vect,max_value):
    Num_Values = Activity
    return np.eye(Num_Values)[np.array(vect, dtype=np.int32)]
###
####
#########################################################################################
Walking=np.transpose(Walking)
Walking=Signal_Arranger(Walking[0:3,:],Walking[3:6,:])
Walking=np.delete(Walking,(0),axis=0)
##print(Walking.shape)
#######################################################################################
Jumping=np.transpose(Jumping)
Jumping=Signal_Arranger(Jumping[0:3,:],Jumping[3:6,:])#,Jiten_resmpld[:,3:6])
Jumping=np.delete(Jumping,(0),axis=0)
##print(Jumping.shape)
########################################################################################
Up_Stair=np.transpose(Up_Stair)
Up_Stair=Signal_Arranger(Up_Stair[0:3,:],Up_Stair[3:6,:])#,Walking_resmpld[:,3:6])
Up_Stair=np.delete(Up_Stair,(0),axis=0)
##print(Up_Stair.shape)
#########################################################################################
Down_Stair=np.transpose(Down_Stair)
Down_Stair=Signal_Arranger(Down_Stair[0:3,:],Down_Stair[3:6,:])#,Walking_resmpld[:,3:6])
Down_Stair=np.delete(Down_Stair,(0),axis=0)
##print(Down_Stair.shape)
#######################################################################################
Running=np.transpose(Running)
Running=Signal_Arranger(Running[0:3,:],Running[3:6,:])#,Walking_resmpld[:,3:6])
Running=np.delete(Running,(0),axis=0)
##print(Sitting.shape)
#######################################################################################
Bike_Riding=np.transpose(Bike_Riding)
Bike_Riding=Signal_Arranger(Bike_Riding[0:3,:],Bike_Riding[3:6,:])#,Walking_resmpld[:,3:6])
Bike_Riding=np.delete(Bike_Riding,(0),axis=0)
##print(Sitting.shape)
#######################################################################################
Still=np.transpose(Still)
Still=Signal_Arranger(Still[0:3,:],Still[3:6,:])#,Walking_resmpld[:,3:6])
Still=np.delete(Still,(0),axis=0)
##print(Sitting.shape)
##############################################################################################
####### Normalization of Frequency signals
Activity_Images=np.concatenate((Walking,Jumping,Up_Stair,Down_Stair,Running,Bike_Riding,Still))         
################################################################################################
Label_0=One_Hot_Vect(0,Activity)
Label_0=np.tile(Label_0,(Walking.shape[0],1))
##
Label_1=One_Hot_Vect(1,Activity)
Label_1=np.tile(Label_1,(Jumping.shape[0],1))

Label_2=One_Hot_Vect(2,Activity)
Label_2=np.tile(Label_2,(Up_Stair.shape[0],1))

Label_3=One_Hot_Vect(3,Activity)
Label_3=np.tile(Label_3,(Down_Stair.shape[0],1))
##
Label_4=One_Hot_Vect(4,Activity)
Label_4=np.tile(Label_4,(Running.shape[0],1))

Label_5=One_Hot_Vect(5,Activity)
Label_5=np.tile(Label_5,(Bike_Riding.shape[0],1))

Label_6=One_Hot_Vect(6,Activity)
Label_6=np.tile(Label_6,(Still.shape[0],1))

Labels=np.concatenate((Label_0,Label_1,Label_2,Label_3,Label_4,Label_5,Label_6))
#print(Labels.shape)
#################################################################################################
Whole_Image_Data = np.concatenate((Activity_Images,Labels),axis=1)
Whole_Image_Data = np.random.permutation(Whole_Image_Data)
np.savetxt("TD_SC.txt",Whole_Image_Data,delimiter=',')
