# -*- coding: UTF-8 -*-
import os.path
import threading

import serial  # 导入模块
import numpy as np
from scipy.fftpack import fft,ifft
import matplotlib.pyplot as plt
import time
import queue

def read_serial_data(ser, data_queue):
    st = time.time()
    while True:
        if ser.in_waiting > 0:
            if time.time() - st > 1000000:
                return
            data = ser.read(sampleSize)
            print("read data length = ", len(data))
            if len(data) !=0:
                data_queue.put(data)

def save_data_to_file(data_queue, filename,light_queue):
    with open(filename, mode='ab') as file:
        while True:
            data = data_queue.get()
            light_queue.put(data)
            file.write(data)
            print("save data length = ", len(data))
            file.flush()  # 立即刷新缓冲区，确保数据写入文件
            data_queue.task_done()

def save_RSS_to_file(data_queue, filename):
    with open(filename, mode='ab') as file:
        while True:
            RSS = data_queue.get()
            if len(RSS)!=0:
                np.savetxt(file, RSS, fmt='%f', delimiter=',')
                file.flush()
            data_queue.task_done()


if __name__ == '__main__':
    try:
        portx = "COM9" # 端口
        # bps = 921600 #921600 # 波特率
        # bps = 1000000  # 921600 # 波特率
        bps = 115200
        timex = 10 # 超时设置,None：永远等待操作，0为立即返回请求结果，其他值为等待超时时间(单位为秒）

        # 定义和打开串口
        ser = serial.Serial(portx, bps, timeout=timex)

        #### 获取当前时间用于定义文件名 ####
        dt = time.time()
        dtime = time.localtime(dt)
        h = str(dtime[3])
        m = str(dtime[4])
        s = str(dtime[5])
        #判断是否是一个字节 如是则是单个
        if len(h) == 1:
            h = '0' + h
        if len(m) == 1:
            m = '0' + m
        if len(s) == 1:
            s = '0' + s

        # 定义文件
        filename = str(dtime[0]) + str(dtime[1]) + str(dtime[2]) + '_' + h + '_' + m + '_' + s + '.txt';

        # 打开文件
        record_dir = "./" # 文件目录
        file_sign = "static"   # 自定义标记
        if os.path.isdir(record_dir):
            print("record_dir exist")
        else:
            os.mkdir(record_dir)

        record_file_light = record_dir + "_Light_" +file_sign+ "_" +filename
        record_file_rss = record_dir + "_RSS_" +file_sign+ "_" +filename

        ### 定义VLP参数 ###
        # Send_freq = [213] # LED灯频率

        Send_freq = [735,215,640,305,865,520] # LED灯频率
        Nled = len(Send_freq)
        Receive_freq = 2000 # 采样率
        sampleSize = 2001  # 串口接收数据频率
        sampleTime = 100  # 采样时常
        FFT_dt = 1
        win_size = FFT_dt*Receive_freq
        RSS = np.zeros((1, Nled))
        # 画出实时RSS值

        fig = plt.figure()
        plt.tight_layout()  # 自动调整子图参数，避免重叠
        plt.ion()  # 打开交互模式
        # ax = fig.add_subplot(1, 1, 1)

        # 存储历史RSS值
        total_RSS = np.array([])
        evn = []
        sign = 0 #标记第一次存RSS值
        ds = time.time()


        # 定义和打开串口
        data_queue = queue.Queue()  # 创建一个队列用于数据传递
        light_queue = queue.Queue()  # 创建一个队列用于数据传递
        rss_queue = queue.Queue()  # 创建一个队列用于数据传递

        # # 创建并启动串口数据读取线程
        # serial_thread = threading.Thread(target=read_serial_data, args=(ser, data_queue))
        # serial_thread.daemon = True
        # serial_thread.start()
        #
        # 创建并启动数据保存线程
        save_thread = threading.Thread(target=save_data_to_file, args=(data_queue, record_file_light,light_queue))
        save_thread.daemon = True
        save_thread.start()

        # 存RSS线程
        save_thread = threading.Thread(target=save_RSS_to_file, args=(rss_queue, record_file_rss))
        save_thread.daemon = True
        save_thread.start()

        # 画图线程
        Total_data = ''
        LightData = []
        sign_start = 0 #第一波数据需要剔除开始的值
        lk = 1
        while (True):
            if time.time() - ds > sampleTime:
                break

            while(len(LightData)<Receive_freq):
                ## 串口读取数据
                data = ser.read(sampleSize)
                print(data)
                if lk == 2:
                    print(1)
                ## 存储数据
                if len(data) != 0:
                    data_queue.put(data)

                ## 将采集所获数据转为numpy 数组
                s = data.decode('utf-8')
                Total_data = Total_data + s
                # 分割字符
                temp_data = Total_data.split(",")
                LightData = temp_data

            if sign_start == 0:
                # 丢掉最后一个空字符
                LightData = LightData[1:]
                sign_start = 1
            lk = lk +1
            temp = LightData[0:win_size]
            print("length of temp = ", len(temp))

            temp2 = LightData[win_size:]
            Total_data = ','.join(temp2)
            LightData = []
            # 获取字符长度
            DataSize = len(temp)
            N = DataSize

            # char 转为 int 类型
            TimporalData = np.zeros((DataSize, 1))
            for i in range(DataSize):
                if temp[i] == '':
                    TimporalData[i] = 0
                else:
                    TimporalData[i] = int(temp[i])
            evn.append(np.mean(TimporalData))

            #### FFT #####
            # 加汉明窗
            w = np.hamming(DataSize)
            TimporalData = TimporalData.flatten()
            sf = w * TimporalData

            # FFT
            yy = fft(sf.T, DataSize)
            yreal = np.abs(yy)
            # yreal = np.abs(yy.real)
            mag = yreal * 2 / N * 1.852
            n = np.arange(0, DataSize, 1)
            f1 = n * Receive_freq / N

            # 提取相对应的RSS值
            for j in range(Nled):
                RSS[0, j] = max(mag[int((Send_freq[j] * N / Receive_freq)) - 5 : int(Send_freq[j] * N / Receive_freq) + 5])
                 # RSS[0, j] = mag[int((Send_freq[j] * N / Receive_freq)) + 0]
            print("RSS is ", RSS)
            rss_queue.put(RSS)

            # 如果第一次则
            if sign == 0:
                total_RSS = RSS
                sign = 1
            else:
                total_RSS = np.vstack((total_RSS, RSS))
            plt.subplot(3, 1, 1)
            plt.cla()
            mag[0:6] = 0
            mag[-6:] = 0
            plt.stem(mag, linefmt='b-', markerfmt='b.', basefmt='r-')

            plt.subplot(3, 1, 2)
            plt.cla()
            colors = ["red", "yellow", "green", "blue", "purple", "gray"]  # Add more colors if needed
            for k in range(len(Send_freq)):
                plt.plot(total_RSS[:, k], color=colors[k], label=str(Send_freq[k]))

            plt.rcParams['font.sans-serif'] = ['SimHei']  # 用来正常显示中文标签SimHei
            plt.rcParams['axes.unicode_minus'] = False  # 用来正常显示负号
            plt.grid(True)  # 添加网格
            # plt.legend([str(Send_freq[0]), str(Send_freq[1]), str(Send_freq[2]), str(Send_freq[3]), str(Send_freq[4])])
            plt.legend(["LED1",  "LED2", "LED3", "LED4", "LED5", "LED6"],ncol=5)
            plt.subplot(3, 1, 3)
            plt.cla()
            plt.plot(np.array(evn))

            plt.pause(0.1)
            # plt.clf()#清除当前的Figure对象
            # plt.cla()  # 清除当前的Axes对象
            # plt.tight_layout()  # 自动调整子图参数，避免重叠
            dt1 = time.time()
            print("---------------",(dt1-ds))

    except Exception as e:
        print("---异常---：", e)

        ser.close()


