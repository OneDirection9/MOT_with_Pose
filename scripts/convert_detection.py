#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author: WarmerHan
# Time: 17-8-29 下午8:25
# File: convert.py
# Software: PyCharm

import os
import codecs
import argparse
import subprocess
import shutil

def allFiles(root):
    files = []

    for parent, dirnames, filenames in os.walk(root):
        for filename in filenames:
            files.append(os.path.join(parent, filename))

    return files


def deleteVideoName(path):
    files = [x for x in os.listdir(path) if x.endswith('txt')]

    for file in files:
        file = os.path.join(path, file)
        print("Converting %s" % file)
        os.system("sed -i -e 's/.*\///g' %s" % file)
        os.system("sed -i -e 's/.jpg//g' %s" % file)


def convert(source_file, save_dir):
    det_file = codecs.open(source_file, 'r', 'utf-8')

    if os.path.exists(save_dir):
        shutil.rmtree(save_dir)
    os.mkdir(save_dir)

    result = dict()

    for line in det_file.readlines():
        vidx = line.split('/')[0]
        if not result.__contains__(vidx):
            result[vidx] = []
        result[vidx].append(line)

    for key, value in result.items():
        save_file = os.path.join(save_dir, key + '.txt')
        output = codecs.open(save_file, 'w', 'utf-8')

        for line in value:
            output.write(line)

    deleteVideoName(save_dir)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument('--source-file', type=str)
    parser.add_argument('--save-dir', type=str)

    args = parser.parse_args()
    convert(args.source_file, args.save_dir)
