# 这是一个示例 Python 脚本。

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


# coding=utf-8
file1 = open('numbers.txt', 'r', encoding='utf-8')
file2 = open('Serial_Debug3.txt', 'r', encoding='utf-8')
content1 = file1.read()
content2 = file2.read()
file1.close()
file2.close()

import random
import string

def generate_random_string(length):
    f= open("numbers.txt", "w")
    letters = string.ascii_lowercase + string.ascii_uppercase + string.digits
    for i in range(length):
        f.write(random.choice(letters))
    f.close()
    # return ''.join(random.choice(letters) for i in range(length))

def testsame():
    # while True:
        if content1 == content2:
            print("file content same")
        else:
            print("file content not same")


if __name__ == '__main__':
    # generate_random_string(1000000)
    testsame()