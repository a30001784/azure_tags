#!/usr/bin/env python

import os
from pyrfc import Connection

def main():
    # Set up connection to PAS  
    conn = Connection(ashost='azsaw0607.agl.int', sysnr='10', client='100', user='AGLSRVUSR', passwd=os.environ["SAP_RFC_PASSWORD"])

    print(conn.call("BP_SCHEDULE_STANDARDJOBS", SCHEDULE_MODE="ALL"))

main()