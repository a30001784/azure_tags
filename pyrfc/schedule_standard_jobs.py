#!/usr/bin/env python

import argparse
from pyrfc import Connection

def main():
    parser = argparse.ArgumentParser(description="SAP users creation")
    parser.add_argument("-a", "--as-hostname", type=str, required=True, help="Application server hostname")
    parser.add_argument("-u", "--as-username", type=str, required=True, help="Application server username")
    parser.add_argument("-p", "--as-password", type=str, required=True, help="Application server password")
    args = parser.parse_args()

    # Set up connection to PAS  
    conn = Connection(ashost=args.as_hostname, sysnr='10', client='100', user=args.as_username, passwd=args.as_password)

    print(conn.call("BP_SCHEDULE_STANDARDJOBS", SCHEDULE_MODE="ALL"))

main()