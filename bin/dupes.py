#!/usr/bin/env python3

from collections import defaultdict
import os
import sys


def files_are_identical(file1, file2, chunk_size=8192):
    '''Compare two files byte-by-byte to check if they are identical.'''
    with open(file1, 'rb') as f1, open(file2, 'rb') as f2:
        while True:
            chunk1 = f1.read(chunk_size)
            chunk2 = f2.read(chunk_size)

            if chunk1 != chunk2:
                return False
            if not chunk1:  # End of file reached
                return True


def find_duplicates(root_folder):
    '''Find duplicate files in the specified folder recursively.'''
    files_by_size = defaultdict(list)
    duplicates = []

    # Traverse the directory tree
    for dirpath, _, filenames in os.walk(root_folder):
        for filename in filenames:
            file_path = os.path.join(dirpath, filename)
            file_size = os.path.getsize(file_path)

            # Group files by their size
            files_by_size[file_size].append(file_path)

    # Compare files with the same size
    for files in filter(lambda f: len(f) > 1, files_by_size.values()):
        for idx, file1 in enumerate(files):
            for file2 in files[idx + 1:]:
                if files_are_identical(file1, file2):
                    duplicates.append((file1, file2))

    return duplicates


if __name__ == '__main__':
    if len(sys.argv) != 2:
        raise Exception('Invalid args')
    folder_to_check = sys.argv[1]
    print(f'Scanning folder {os.path.abspath(folder_to_check)}')

    duplicate_files = find_duplicates(folder_to_check)
    if duplicate_files:
        print('Duplicate files found:')
        for file1, file2 in duplicate_files:
            print(f'{file1} and {file2}')
    else:
        print('No duplicate files found.')
