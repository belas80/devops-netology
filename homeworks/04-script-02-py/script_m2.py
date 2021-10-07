#!/usr/bin/env python3

import os
import sys  # добавим модуль sys чтобы принимать параметры

if len(sys.argv) > 1:       # если кол-во входных данных больше одного то
    myDir = sys.argv[1]     # путь будет указанный в параметре
else:
    myDir = '.'             # иначе, будем использовать текущую директорию

os.chdir(myDir)             # меняем рабочую директорию

result_os = os.popen("git status").read()   # убрал все лишнее, "git status" будет достаточно
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = os.path.abspath(result.replace('\tmodified:   ', ''))  # ну и добавляем полный путь
        print (prepare_result)
