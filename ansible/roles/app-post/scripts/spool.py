#!/usr/bin/env python

import argparse
from pyrfc import Connection

def main():
    # Parse command line args
    parser = argparse.ArgumentParser(description="Re-assign and clean up spool")
    parser.add_argument("-a", "--as-hostname", type=str, required=True, help="Application server hostname")
    parser.add_argument("-u", "--as-username", type=str, required=True, help="Application server username")
    parser.add_argument("-p", "--as-password", type=str, required=True, help="Application server password")
    args = parser.parse_args()

    # Set up connection
    conn = Connection(ashost=args.as_hostname, sysnr='10', client='100', user=args.as_username, passwd=args.as_password)

    print(conn.call("Z_IBA_ASSIGN_SPOOLSERVER"))

    para = [
        {
            "PARA_NAME": "SEL_OLDI",
            "PARA_VALUE": "X"
        },
        {
            "PARA_NAME": "MIN_ALT",
            "PARA_VALUE": "2"
        },
        {
            "PARA_NAME": "SEL_PRIN",
            "PARA_VALUE": "X"
        },
        {
            "PARA_NAME": "SEL_ALL",
            "PARA_VALUE": "X"
        },
        {
            "PARA_NAME": "LISTONLY",
            "PARA_VALUE": ""
        },
        { 
            "PARA_NAME": "EXEMODE",
            "PARA_VALUE": "BATCH"
        }
    ]

    print(conn.call("INST_EXECUTE_REPORT", PROGRAM="RSPO0041", PARA=para))

main()