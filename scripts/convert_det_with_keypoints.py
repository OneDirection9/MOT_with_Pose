#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author: WarmerHan
# Time: 17-9-23 下午2:38
# File: convert_det_with_keypoints.py
# Software: PyCharm

import argparse
import codecs
import os
import shutil

import numpy as np


def deleteVideoName(path):
    files = [x for x in os.listdir(path) if x.endswith('txt')]

    for file in files:
        file = os.path.join(path, file)
        print("Deleting name and .jpg for %s" % file)
        os.system("sed -i -e 's/.*\///g' %s" % file)
        os.system("sed -i -e 's/.jpg//g' %s" % file)


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
            assert nums % 16 == 0, 'Does not match 1:16.'

            box_nums = int(nums / 16)
            box_l = [_ for _ in range(box_nums)]
            key_l = [[] for _ in range(box_nums)]
            index = 0
            for i in range(0, nums, 16):
                box = lines[i]
                box_l[index] = box
                for j in range(i + 1, i + 16):
                    key_l[index].append(lines[j])
                index += 1

            npa = np.array(box_l)
            arg_idx = np.argsort(npa)
            count = 0
            for i in range(box_nums):
                id = arg_idx[i]
                count += 1
                box_out.write(box_l[id])
                frame_idx = box_l[id].split(' ')[0]
                for line in key_l[id]:
                    keypoint_out.write(str(count) + ' ' + frame_idx + ' ' + line)

        box_out.close()
        keypoint_out.close()


def convert(file, save_dir, box_save_dir, key_save_dir):
    assert (os.path.exists(file) != 0);

    if os.path.exists(save_dir):
        print('Directory {} alredy exists, deleted.'.format(save_dir))
        shutil.rmtree(save_dir)
    os.mkdir(save_dir)

    result = dict()

    with codecs.open(file, 'r', encoding='utf-8', buffering=0) as f:
        lines = f.readlines()
        nums = len(lines)

        for i in range(0, nums, 16):
            vidx = lines[i].split('/')[0]

            if not result.__contains__(vidx):
                result[vidx] = []

            for j in range(i, i + 16):
                if j > nums or (j != i and '/' in lines[j]):
                    assert False, 'Does not match 1:16.'
                result[vidx].append(lines[j])

    for key, value in result.items():
        save_file = os.path.join(save_dir, key + '.txt')

        with codecs.open(save_file, 'w', 'utf-8') as f:
            for i in range(0, len(value)):
                f.write(value[i])

    deleteVideoName(save_dir)
    map(save_dir, box_save_dir, key_save_dir)


if __name__ == "__main__":
    parser = argparse.ArgumentParser("Need source file and save directory.")

    parser.add_argument('-f', dest='file', default='posetrack_val_hzp_nms03_sc05_keypoints.txt',
                        help='File with detection boxes and keypoints.')
    parser.add_argument('-d', dest='save_dir', default='../data/box_with_keypoints', help='Directory to save files.')
    parser.add_argument('-b', dest='box', default='../data/detections_txt')
    parser.add_argument('-k', dest='key', default='../data/keypoints_txt')
    args = parser.parse_args()

    convert(args.file, args.save_dir, args.box, args.key)

    print("Done!");
