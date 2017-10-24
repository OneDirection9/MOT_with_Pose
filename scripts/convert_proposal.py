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


def convert(source_file, save_dir):
    det_file = codecs.open(source_file, 'r', 'utf-8')

    if os.path.exists(save_dir):
        shutil.rmtree(save_dir)
    os.mkdir(save_dir)

    # key is video name, value is proposals
    result = dict()
    for line in det_file.readlines():
        vidx = line.split('/')[0]
        if not result.__contains__(vidx):
            result[vidx] = []
        result[vidx].append(line)
    det_file.close()

    total = len(result)
    count = 1
    for key, value in result.items():
        print('Porcessing {}.\t{:<4}/{}'.format(key, count, total))
        count += 1

        save_video_dir = os.path.join(save_dir, key)
        os.mkdir(save_video_dir)

        # key is frame, i.e. 00001
        # value is proposals
        frames = dict()
        for val in value:
            frame = val.split('/')[1].split('.')[0]

            if not frames.__contains__(frame):
                frames[frame] = []
            frames[frame].append(val)

        for frame, lines in frames.items():
            save_file = os.path.join(save_video_dir, frame + '.txt')
            output = codecs.open(save_file, 'w', 'utf-8')

            for line in lines:
                output.write(line)
            output.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument('--source-file', type=str)
    parser.add_argument('--save-dir', type=str)

    args = parser.parse_args()
    convert(args.source_file, args.save_dir)
