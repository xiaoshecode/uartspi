# 这是一个示例 Python 脚本。
import binascii

# 按 Shift+F10 执行或将其替换为您的代码。
# 按 双击 Shift 在所有地方搜索类、文件、工具窗口、操作和设置。

#
# def print_hi(name):
#     # 在下面的代码行中使用断点来调试脚本。
#     print(f'Hi, {name}')  # 按 Ctrl+F8 切换断点。
#
#
# # 按间距中的绿色按钮以运行脚本。
# if __name__ == '__main__':
#     print_hi('PyCharm')
#
# # 访问 https://www.jetbrains.com/help/pycharm/ 获取 PyCharm 帮助


import random
import serial
import serial.tools.list_ports

port = "COM4"   #端口
baudrate = 1500000 #波特率,
bytesize = 8    #字节大小,为每个字节的比特数
parity = 'O'    #校验位选择，程序目前默认为Odd奇校验模式
stopbits = 1    #停止位，用来指示字节完成
timeout = 1     #读出超时设置


def serial_use(test_duration):
    ser = serial.Serial(port=port, baudrate=baudrate, bytesize=bytesize, parity=parity, stopbits=stopbits,
                        timeout=timeout)  # 创建serial对象

    valid_data_num = 0
    for n in range (test_duration):
        data_test = []
        for i in range(4):
            random_num = generate_random_hexnum()
            data_test.append(random_num)

        # print("data is:", data_test)
        ser.write(data_test)
        result = ser.read(4)
        data_str = list_to_hex_string(data_test)

        hex_res = binascii.hexlify(result)
        rst_str = hex_res.decode('utf-8')
        print("input data is:", data_str)
        print("result data is:", rst_str)
        if data_str == rst_str:
            valid_data_num = valid_data_num + 1
    # print(valid_data_num)
    return valid_data_num


# 将输入数据转成str方便后期比较
def list_to_hex_string(list_data):
    list_str = ''
    for x in list_data:
        list_str += '{:02x}'.format(x)
    return list_str

# 产生1字节随机数据
def generate_random_hexnum():
    random_number = random.randint(0, 255)
    return random_number


if __name__ == '__main__':
    test_num = 1000000     # 测试发送多少次数据
    valid_num = serial_use(test_num)
    print("Test how many times:", test_num)
    print("How many data received valid:", valid_num)
    print("Data valid rate is:", valid_num/test_num)




# def str_to_hexStr(string):
#     str_bin = string.encode('utf-8')
#     return binascii.hexlify(str_bin).decode('utf-8')
#
# def generate_random_string(length):
#     f= open("numbers.txt", "w")
#     letters = string.ascii_lowercase + string.ascii_uppercase + string.digits
#     for i in range(length):
#         f.write(random.choice(letters))
#     f.close()
#     # return ''.join(random.choice(letters) for i in range(length))

    # random_num = generate_random_hexnum()
    # data_test.append(random_num)
    # print("data_i type is:",type(data_i) )
    # data = generate_random_hexnum()

    # letters = string.ascii_lowercase + string.ascii_uppercase + string.digits
    # for i in range(4):
    #     data_sent ="".join(letters)
    # encode_letters = str_to_hexStr(data_sent)
    # # hex_datain = binascii.hexlify(encode_letters)
    # print("input data is:", encode_letters)
    # data_i = [0xA0, 0xB0, 0xC0, 0xD0, 0x01, 0x02, 0x03, 0x04]



# # coding=utf-8
# file1 = open('numbers.txt', 'r', encoding='utf-8')
# file2 = open('Serial_Debug3.txt', 'r', encoding='utf-8')
# content1 = file1.read()
# content2 = file2.read()
# file1.close()
# file2.close()