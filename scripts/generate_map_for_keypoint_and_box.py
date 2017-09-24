#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author: WarmerHan
# Time: 17-9-23 下午7:14
# File: generate_map_for_keypoint_and_box.py
# Software: PyCharm

import argparse
import os
import sys
import codecs
import shutil


def VerifyDir(*dirs):
    for dir in dirs:
        if os.path.exists(dir):
            print('{} aleady exists, deleted.'.format(dir))
            shutil.rmtree(dir)
        os.mkdir(dir)


def map(dir, box_save_dir, keypoint_save_dir):
    assert os.path.exists(dir) == True, '{} does not exists.'.format(dir)
    names = os.listdir(dir)

    VerifyDir(box_save_dir, keypoint_save_dir)

    for name in names:
        print('Converting {}'.format(name))
        file = os.path.join(dir, name)
        bbox_file = os.path.join(box_save_dir, name)
        keypoint_file = os.path.join(keypoint_save_dir, name)

        box_out = codecs.open(bbox_file, 'w', encoding='utf-8')
        keypoint_out = codecs.open(keypoint_file, 'w', encoding='utf-8')

        with open(file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            nums = len(lines)
            count = 0;
            for i in range(0, nums, 16):
                box = lines[i]
                box_out.write(box)
                count += 1
                for j in range(i + 1, i + 16):
                    line = str(count) + ' ' + lines[j]
                    keypoint_out.write(line)
        box_out.close()
        keypoint_out.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser("Split txt to bbox and keypoints.")

    parser.add_argument('-d', dest='dir', default='../data/box_with_keypoints', type=str,
                        help='Directory to transform.')
    parser.add_argument('-b', dest='box', default='../data/detections_txt', type=str)
    parser.add_argument('-k', dest='key', default='../data/keypoints_txt', type=str)
    args = parser.parse_args()

    map(args.dir, args.box, args.key)
