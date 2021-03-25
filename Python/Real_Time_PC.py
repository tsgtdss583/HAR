import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt
import socket
tf.reset_default_graph()
Activity=8
Chunk_size=60  
def Signal_Arranger(Data1,Data2):
    Raw_size=Data1.shape[1]
    if Raw_size%(Chunk_size/2)==0:
        Counter=Raw_size//(Chunk_size//2)-1
    else:
        Counter=Raw_size//(Chunk_size//2)
    Data_Accum=np.zeros([1,24*Chunk_size])
    for i in range(Counter):
        if i==0:
            Boun_Low=0
            Boun_High=Chunk_size
            
        else:
            Boun_Low=i*(Chunk_size//2)
            Boun_High=Boun_Low+Chunk_size
        if Boun_High>Raw_size:
            Temp_Data1=Data1[:,Raw_size-Chunk_size:Raw_size]
            Temp_Data2=Data2[:,Raw_size-Chunk_size:Raw_size]
            Temp_Data_f1=np.abs(np.fft.fft(Temp_Data1,axis=1))
            Temp_Data_f2=np.abs(np.fft.fft(Temp_Data2,axis=1))
            Temp_Data1=Temp_Data1.reshape(1,-1)
            Temp_Data2=Temp_Data2.reshape(1,-1)
            Temp_Data_f1=Temp_Data_f1.reshape(1,-1)
            Temp_Data_f2=Temp_Data_f2.reshape(1,-1)


            Temp_Freq_Data=np.concatenate((Temp_Data1,Temp_Data1,
                                           Temp_Data2,Temp_Data2,
                                           Temp_Data_f1,Temp_Data_f1,
                                           Temp_Data_f2,Temp_Data_f2),axis=1)
            Data_Accum=np.concatenate((Data_Accum,Temp_Freq_Data))
        else:
            Temp_Data1=Data1[:,Boun_Low:Boun_High]
            Temp_Data2=Data2[:,Boun_Low:Boun_High]
            Temp_Data_f1=np.abs(np.fft.fft(Temp_Data1,axis=1))
            Temp_Data_f2=np.abs(np.fft.fft(Temp_Data2,axis=1))
            Temp_Data1=Temp_Data1.reshape(1,-1)
            Temp_Data2=Temp_Data2.reshape(1,-1)
            Temp_Data_f1=Temp_Data_f1.reshape(1,-1)
            Temp_Data_f2=Temp_Data_f2.reshape(1,-1)


            Temp_Freq_Data=np.concatenate((Temp_Data1,Temp_Data1,
                                           Temp_Data2,Temp_Data2,
                                           Temp_Data_f1,Temp_Data_f1,
                                           Temp_Data_f2,Temp_Data_f2),axis=1)
            Data_Accum=np.concatenate((Data_Accum,Temp_Freq_Data))
    return Data_Accum
##################################################################################
HOST='172.20.10.4'#192.168.11.5'#'192.168.11.4' #'127.0.0.1'# # Standard loopback interface address (localhost)
PORT = 1337        # Port to listen on (non-privileged ports are > 1023)9
k=0
s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))
sess=tf.Session()    
sess.run(tf.global_variables_initializer())
saver = tf.train.import_meta_graph('/AROB2_BothData_APP_1/parameters-1500.meta')
saver.restore(sess,tf.train.latest_checkpoint('/AROB2_BothData_APP_1/'))

graph = tf.get_default_graph()
x_data=graph.get_tensor_by_name("inputData:0")
isTraining=graph.get_tensor_by_name("isTraining:0")
#bba = graph.get_tensor_by_name("filt:0")
proba=graph.get_tensor_by_name("softmaxProbability:0")
Activity_decider=tf.argmax(proba,1)
allActivityList=["Walking...","Jumping...","Up_Stair...","Down_Stair..."
                 ,"Running...","Bike_Riding...","Sitting...","Standing..."]
print("connected.............")
garbageCollector = ''
while k<15:
    keyValueholder = []
    for j in range (50):
        returnValue = s.recv(2550)
    #    print(returnValue)
        if returnValue == '':
            print ("Nooooooo")
            break
        returnValueDecoded = returnValue.decode("utf-8")
#        if garbageCollector!='':
#            returnValueDecoded = garbageCollector + returnValueDecoded
        listreturnvalueDecoded = returnValueDecoded.split('\n')
        listreturnvalueDecoded = filter(None,listreturnvalueDecoded)
            
        for i in listreturnvalueDecoded:
            tempHolder = i.split(',')
            lentempHolder = len(tempHolder)
            if(lentempHolder == 6):
                keyValueholder.append(list(map(float, tempHolder)))
            else:
                garbageCollector = i
        
            
    keyValueholder=np.asarray(keyValueholder)
    keyValueholder=keyValueholder.reshape(-1,6)
    ################################################
    realTimeData=keyValueholder
    #np.savetxt('natey1.txt',Video_File,delimiter=',')
    #print(realTimeData.shape)
    realTimeData=np.transpose(realTimeData)
    realTimeData=Signal_Arranger(realTimeData[0:3,:],realTimeData[3:6,:])
    realTimeData=np.delete(realTimeData,(0),axis=0)
    actIndex=sess.run(Activity_decider,feed_dict={x_data:realTimeData,isTraining:False})
    for i in actIndex:
        print(np.take(allActivityList,i))
    k+=1
    #    
    #act=["walking...","jumping...","upstair..."]
    #d=np.array([0,1,2,2])
    #for i in d:
    #    print(np.take(act,d[i]))