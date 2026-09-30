#!/usr/bin/env python3

from __future__ import print_function

import socket
import ssl
import http.client
import json
import os
import math
import time
from random import randrange
from hashlib import pbkdf2_hmac
import base64
from binascii import hexlify
import argparse


# 0.15.0
#iKrsVMAFrzd75voT
SALT_DEFAULT_B64 = 'VGltZVRvRHVlbA=='
SALT_SERVICE_OLD_B64 = 'iKrsVMAFrzd75voT' #XOl9vG7VE6YgUvkV
SALT_SERVICE_B64 = 'VGltZVRvRHVlbA==' #XOl9vG7VE6YgUvkV
HASH_ALGORITHM = "sha256"
HASH_ITERATIONS = 1000
HASH_KEY_LEN = 20



def generateHash(salt, password):
    salt = base64.b64decode(salt)

    dk = pbkdf2_hmac(
        hash_name=HASH_ALGORITHM,
        password=password.encode("UTF-8"),
        salt=salt,
        iterations=HASH_ITERATIONS,
        dklen=HASH_KEY_LEN
    )

    #print('Before encode: {}'.format(dk))

    return base64.b64encode(bytearray(dk)).decode("UTF-8")


def getDefaultPassword(objectId):
    dk = generateHash(SALT_DEFAULT_B64, objectId)

    #print("DefaultPassword for " + objectId + ": " + dk)
    return dk


def getSSAPassword(objectId):
    dk = generateHash(SALT_SERVICE_B64, objectId)
    print(dk)
    dk = generateHash(SALT_SERVICE_OLD_B64, objectId)
    print("old: ", dk)
    return hash


def main():
    parser = argparse.ArgumentParser(description='Argument parsing')
    parser.add_argument('object_id')
    args = parser.parse_args()

    defaultPassword = getDefaultPassword(args.object_id)
    SSApassword = getSSAPassword(args.object_id)


if __name__ == "__main__":
    main()
